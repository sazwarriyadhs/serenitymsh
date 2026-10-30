$ErrorActionPreference = "Stop"
Set-Location "D:\SERENITY-HMS"

Write-Host "=== Serenity HMS Authentication Installer ===" -ForegroundColor Cyan

# Keep timestamped copies of files this installer changes.
$backupRoot = Join-Path ".\storage\backups" ("auth-install-" + (Get-Date -Format "yyyyMMdd-HHmmss"))
New-Item -ItemType Directory -Force -Path $backupRoot | Out-Null
foreach ($file in @(
    ".\backend\internal\config\config.go",
    ".\backend\internal\httpapi\server.go",
    ".\backend\cmd\api\main.go"
)) {
    if (Test-Path $file) {
        Copy-Item $file (Join-Path $backupRoot ($file -replace '[\\/:]', '_')) -Force
    }
}

New-Item -ItemType Directory -Force -Path ".\backend\internal\auth" | Out-Null

@'
package config

import (
    "fmt"
    "os"
    "strconv"
)

type Config struct {
    DatabaseURL string
    APIPort     string
    JWTSecret   string
}

func Load() (Config, error) {
    databaseURL := os.Getenv("DATABASE_URL")
    if databaseURL == "" {
        return Config{}, fmt.Errorf("DATABASE_URL is required")
    }

    port := os.Getenv("API_PORT")
    if port == "" {
        port = "8080"
    }
    n, err := strconv.Atoi(port)
    if err != nil || n < 1 || n > 65535 {
        return Config{}, fmt.Errorf("API_PORT must be between 1 and 65535")
    }

    jwtSecret := os.Getenv("JWT_SECRET")
    if len(jwtSecret) < 32 {
        return Config{}, fmt.Errorf("JWT_SECRET is required and must be at least 32 characters")
    }

    return Config{DatabaseURL: databaseURL, APIPort: port, JWTSecret: jwtSecret}, nil
}
'@ | Set-Content -Encoding utf8 ".\backend\internal\config\config.go"

@'
package auth

import (
    "context"
    "encoding/json"
    "errors"
    "io"
    "net/http"
    "strings"
    "time"

    "github.com/golang-jwt/jwt/v5"
    "github.com/jackc/pgx/v5/pgxpool"
    "golang.org/x/crypto/bcrypt"
)

type Service struct {
    pool *pgxpool.Pool
    jwtSecret []byte
}

type Claims struct {
    UserID string `json:"user_id"`
    OrganizationID string `json:"organization_id"`
    Email string `json:"email"`
    jwt.RegisteredClaims
}

type registerRequest struct {
    OrganizationName string `json:"organization_name"`
    PropertyName string `json:"property_name"`
    Timezone string `json:"timezone"`
    Name string `json:"name"`
    Email string `json:"email"`
    Password string `json:"password"`
}

type loginRequest struct {
    OrganizationID string `json:"organization_id"`
    Email string `json:"email"`
    Password string `json:"password"`
}

type userRecord struct {
    ID string `json:"user_id"`
    OrganizationID string `json:"organization_id"`
    PropertyID string `json:"property_id,omitempty"`
    Name string `json:"name"`
    Email string `json:"email"`
    Role string `json:"role,omitempty"`
}

type authResponse struct {
    Token string `json:"token"`
    User userRecord `json:"user"`
}

type errorResponse struct {
    Error string `json:"error"`
}

func New(pool *pgxpool.Pool, secret string) *Service {
    return &Service{pool: pool, jwtSecret: []byte(secret)}
}

func (s *Service) Register(w http.ResponseWriter, r *http.Request) {
    var req registerRequest
    if err := decodeJSON(r, &req); err != nil {
        writeError(w, http.StatusBadRequest, "invalid JSON body")
        return
    }

    req.OrganizationName = strings.TrimSpace(req.OrganizationName)
    req.PropertyName = strings.TrimSpace(req.PropertyName)
    req.Name = strings.TrimSpace(req.Name)
    req.Email = strings.ToLower(strings.TrimSpace(req.Email))
    req.Timezone = strings.TrimSpace(req.Timezone)
    if req.Timezone == "" {
        req.Timezone = "Asia/Jakarta"
    }
    if req.OrganizationName == "" || req.PropertyName == "" || req.Name == "" ||
        req.Email == "" || !strings.Contains(req.Email, "@") || len(req.Password) < 12 {
        writeError(w, http.StatusBadRequest, "organization_name, property_name, name, valid email, and password of at least 12 characters are required")
        return
    }
    if len(req.Password) > 72 {
        writeError(w, http.StatusBadRequest, "password must be at most 72 bytes")
        return
    }
    if _, err := time.LoadLocation(req.Timezone); err != nil {
        writeError(w, http.StatusBadRequest, "timezone must be a valid IANA timezone")
        return
    }

    passwordHash, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
    if err != nil {
        writeError(w, http.StatusInternalServerError, "could not secure password")
        return
    }

    ctx, cancel := context.WithTimeout(r.Context(), 8*time.Second)
    defer cancel()
    tx, err := s.pool.Begin(ctx)
    if err != nil {
        writeError(w, http.StatusInternalServerError, "database transaction could not start")
        return
    }
    defer func() { _ = tx.Rollback(ctx) }()

    var orgID, propertyID, roleID, userID string
    err = tx.QueryRow(ctx,
        `INSERT INTO organizations (name, status) VALUES ($1, 'active') RETURNING id::text`,
        req.OrganizationName).Scan(&orgID)
    if err != nil {
        writeError(w, http.StatusInternalServerError, "could not create organization")
        return
    }
    err = tx.QueryRow(ctx,
        `INSERT INTO properties (organization_id, name, timezone, status)
         VALUES ($1::uuid, $2, $3, 'active') RETURNING id::text`,
        orgID, req.PropertyName, req.Timezone).Scan(&propertyID)
    if err != nil {
        writeError(w, http.StatusInternalServerError, "could not create property")
        return
    }
    err = tx.QueryRow(ctx,
        `INSERT INTO roles (organization_id, name, description)
         VALUES ($1::uuid, 'organization_admin', 'Administrator for the organization')
         RETURNING id::text`, orgID).Scan(&roleID)
    if err != nil {
        writeError(w, http.StatusInternalServerError, "could not create administrator role")
        return
    }
    err = tx.QueryRow(ctx,
        `INSERT INTO users (organization_id, display_name, email, password_hash, status)
         VALUES ($1::uuid, $2, $3, $4, 'active') RETURNING id::text`,
        orgID, req.Name, req.Email, string(passwordHash)).Scan(&userID)
    if err != nil {
        writeError(w, http.StatusConflict, "could not create user; registration was rolled back")
        return
    }
    if _, err = tx.Exec(ctx,
        `INSERT INTO user_roles (user_id, role_id, property_id)
         VALUES ($1::uuid, $2::uuid, $3::uuid)`, userID, roleID, propertyID); err != nil {
        writeError(w, http.StatusInternalServerError, "could not assign administrator role")
        return
    }
    if _, err = tx.Exec(ctx,
        `INSERT INTO audit_logs (organization_id, property_id, actor_user_id, action, entity_type, entity_id, metadata)
         VALUES ($1::uuid, $2::uuid, $3::uuid, 'auth.register', 'user', $3, jsonb_build_object('email', $4))`,
        orgID, propertyID, userID, req.Email); err != nil {
        writeError(w, http.StatusInternalServerError, "could not write audit event")
        return
    }
    if err = tx.Commit(ctx); err != nil {
        writeError(w, http.StatusInternalServerError, "could not commit registration")
        return
    }

    token, err := s.issueToken(userID, orgID, req.Email)
    if err != nil {
        writeError(w, http.StatusInternalServerError, "could not issue access token")
        return
    }
    writeJSON(w, http.StatusCreated, authResponse{
        Token: token,
        User: userRecord{ID: userID, OrganizationID: orgID, PropertyID: propertyID,
            Name: req.Name, Email: req.Email, Role: "organization_admin"},
    })
}

func (s *Service) Login(w http.ResponseWriter, r *http.Request) {
    var req loginRequest
    if err := decodeJSON(r, &req); err != nil {
        writeError(w, http.StatusBadRequest, "invalid JSON body")
        return
    }
    req.OrganizationID = strings.TrimSpace(req.OrganizationID)
    req.Email = strings.ToLower(strings.TrimSpace(req.Email))
    if req.OrganizationID == "" || req.Email == "" || req.Password == "" {
        writeError(w, http.StatusBadRequest, "organization_id, email, and password are required")
        return
    }

    ctx, cancel := context.WithTimeout(r.Context(), 5*time.Second)
    defer cancel()
    var userID, orgID, email, displayName, passwordHash, status string
    err := s.pool.QueryRow(ctx,
        `SELECT id::text, organization_id::text, email, display_name, password_hash, status
         FROM users WHERE organization_id = $1::uuid AND lower(email) = $2`,
        req.OrganizationID, req.Email,
    ).Scan(&userID, &orgID, &email, &displayName, &passwordHash, &status)
    if err != nil || status != "active" || bcrypt.CompareHashAndPassword([]byte(passwordHash), []byte(req.Password)) != nil {
        writeError(w, http.StatusUnauthorized, "invalid credentials")
        return
    }

    var propertyID, roleName string
    _ = s.pool.QueryRow(ctx,
        `SELECT ur.property_id::text, r.name
         FROM user_roles ur JOIN roles r ON r.id = ur.role_id
         WHERE ur.user_id = $1::uuid
         ORDER BY ur.created_at LIMIT 1`, userID,
    ).Scan(&propertyID, &roleName)

    token, err := s.issueToken(userID, orgID, email)
    if err != nil {
        writeError(w, http.StatusInternalServerError, "could not issue access token")
        return
    }
    writeJSON(w, http.StatusOK, authResponse{
        Token: token,
        User: userRecord{ID: userID, OrganizationID: orgID, PropertyID: propertyID,
            Name: displayName, Email: email, Role: roleName},
    })
}

func (s *Service) Me(w http.ResponseWriter, r *http.Request) {
    header := strings.TrimSpace(r.Header.Get("Authorization"))
    parts := strings.SplitN(header, " ", 2)
    if len(parts) != 2 || !strings.EqualFold(parts[0], "Bearer") || parts[1] == "" {
        writeError(w, http.StatusUnauthorized, "bearer token required")
        return
    }
    claims := &Claims{}
    token, err := jwt.ParseWithClaims(parts[1], claims, func(token *jwt.Token) (any, error) {
        if token.Method != jwt.SigningMethodHS256 {
            return nil, errors.New("unexpected signing method")
        }
        return s.jwtSecret, nil
    }, jwt.WithIssuer("serenity-hms"))
    if err != nil || !token.Valid {
        writeError(w, http.StatusUnauthorized, "invalid or expired token")
        return
    }

    ctx, cancel := context.WithTimeout(r.Context(), 5*time.Second)
    defer cancel()
    var displayName, email, status string
    err = s.pool.QueryRow(ctx,
        `SELECT display_name, email, status FROM users
         WHERE id = $1::uuid AND organization_id = $2::uuid`,
        claims.UserID, claims.OrganizationID,
    ).Scan(&displayName, &email, &status)
    if err != nil || status != "active" {
        writeError(w, http.StatusUnauthorized, "user is unavailable")
        return
    }
    writeJSON(w, http.StatusOK, map[string]any{
        "user_id": claims.UserID, "organization_id": claims.OrganizationID,
        "name": displayName, "email": email,
    })
}

func (s *Service) issueToken(userID, orgID, email string) (string, error) {
    now := time.Now()
    claims := Claims{
        UserID: userID, OrganizationID: orgID, Email: email,
        RegisteredClaims: jwt.RegisteredClaims{
            Issuer: "serenity-hms", Subject: userID,
            IssuedAt: jwt.NewNumericDate(now), NotBefore: jwt.NewNumericDate(now),
            ExpiresAt: jwt.NewNumericDate(now.Add(8 * time.Hour)),
        },
    }
    return jwt.NewWithClaims(jwt.SigningMethodHS256, claims).SignedString(s.jwtSecret)
}

func decodeJSON(r *http.Request, target any) error {
    defer r.Body.Close()
    decoder := json.NewDecoder(io.LimitReader(r.Body, 1<<20))
    decoder.DisallowUnknownFields()
    if err := decoder.Decode(target); err != nil {
        return err
    }
    var extra any
    if err := decoder.Decode(&extra); err != io.EOF {
        return errors.New("request must contain exactly one JSON object")
    }
    return nil
}

func writeError(w http.ResponseWriter, status int, message string) {
    writeJSON(w, status, errorResponse{Error: message})
}

func writeJSON(w http.ResponseWriter, status int, body any) {
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(status)
    _ = json.NewEncoder(w).Encode(body)
}
'@ | Set-Content -Encoding utf8 ".\backend\internal\auth\auth.go"

@'
ALTER TABLE users
    ADD COLUMN IF NOT EXISTS display_name TEXT NOT NULL DEFAULT '';
'@ | Set-Content -Encoding utf8 ".\database\migrations\007_users_display_name.sql"

@'
package httpapi

import (
    "context"
    "encoding/json"
    "net/http"
    "time"

    "github.com/jackc/pgx/v5/pgxpool"
    "serenity-hms/backend/internal/auth"
)

type response struct {
    Status string `json:"status"`
}

func New(pool *pgxpool.Pool, jwtSecret string) http.Handler {
    mux := http.NewServeMux()
    authService := auth.New(pool, jwtSecret)

    mux.HandleFunc("GET /health", func(w http.ResponseWriter, r *http.Request) {
        writeJSON(w, http.StatusOK, response{Status: "ok"})
    })
    mux.HandleFunc("GET /ready", func(w http.ResponseWriter, r *http.Request) {
        ctx, cancel := contextWithTimeout(r)
        defer cancel()
        if err := pool.Ping(ctx); err != nil {
            writeJSON(w, http.StatusServiceUnavailable, response{Status: "not_ready"})
            return
        }
        writeJSON(w, http.StatusOK, response{Status: "ready"})
    })
    mux.HandleFunc("POST /auth/register", authService.Register)
    mux.HandleFunc("POST /auth/login", authService.Login)
    mux.HandleFunc("GET /auth/me", authService.Me)
    return mux
}

func contextWithTimeout(r *http.Request) (context.Context, context.CancelFunc) {
    return context.WithTimeout(r.Context(), 3*time.Second)
}

func writeJSON(w http.ResponseWriter, status int, body any) {
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(status)
    _ = json.NewEncoder(w).Encode(body)
}
'@ | Set-Content -Encoding utf8 ".\backend\internal\httpapi\server.go"

@'
package main

import (
    "context"
    "errors"
    "fmt"
    "log"
    "net/http"
    "os"
    "os/signal"
    "syscall"
    "time"

    "serenity-hms/backend/internal/config"
    "serenity-hms/backend/internal/database"
    "serenity-hms/backend/internal/httpapi"
)

func main() {
    if err := run(); err != nil {
        log.Fatal(err)
    }
}

func run() error {
    cfg, err := config.Load()
    if err != nil {
        return err
    }
    ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
    defer stop()

    pool, err := database.Open(ctx, cfg.DatabaseURL)
    if err != nil {
        return err
    }
    defer pool.Close()

    command := "serve"
    if len(os.Args) > 1 {
        command = os.Args[1]
    }

    switch command {
    case "migrate":
        return database.ApplyMigrations(ctx, pool)
    case "serve":
        server := &http.Server{
            Addr: ":" + cfg.APIPort,
            Handler: httpapi.New(pool, cfg.JWTSecret),
            ReadHeaderTimeout: 5 * time.Second,
        }
        errCh := make(chan error, 1)
        go func() {
            log.Printf("Serenity API listening on :%s", cfg.APIPort)
            errCh <- server.ListenAndServe()
        }()
        select {
        case err := <-errCh:
            if errors.Is(err, http.ErrServerClosed) {
                return nil
            }
            return fmt.Errorf("HTTP server: %w", err)
        case <-ctx.Done():
            shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
            defer cancel()
            return server.Shutdown(shutdownCtx)
        }
    default:
        return fmt.Errorf("unknown command %q; use serve or migrate", command)
    }
}
'@ | Set-Content -Encoding utf8 ".\backend\cmd\api\main.go"

Write-Host "`n=== ADD AUTH DEPENDENCIES ===" -ForegroundColor Cyan
go get github.com/golang-jwt/jwt/v5 golang.org/x/crypto/bcrypt
if ($LASTEXITCODE -ne 0) { throw "go get failed. Check network/proxy and retry." }

Write-Host "`n=== FORMAT GO FILES ===" -ForegroundColor Cyan
gofmt -w .\backend\internal\config\config.go .\backend\internal\auth\auth.go .\backend\internal\httpapi\server.go .\backend\cmd\api\main.go
if ($LASTEXITCODE -ne 0) { throw "gofmt failed." }

Write-Host "`n=== TEST COMPILE ===" -ForegroundColor Cyan
go test ./...
if ($LASTEXITCODE -ne 0) { throw "go test failed. Do not run migrations until build errors are fixed." }

Write-Host "`n=== AUTH INSTALL FILES CREATED ===" -ForegroundColor Green
Write-Host "Backups: $backupRoot"
Write-Host "Next: set DATABASE_URL, API_PORT, JWT_SECRET; run migration; then start API."
