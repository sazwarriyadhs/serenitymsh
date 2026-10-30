package auth

import (
	"context"
	"encoding/json"
	"errors"
	"io"
	"log"
	"net/http"
	"strings"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"golang.org/x/crypto/bcrypt"
)

type Service struct {
	pool          *pgxpool.Pool
	jwtSecret     []byte
	accountActive func(context.Context, string, string) (bool, error)
}

type Claims struct {
	UserID         string `json:"user_id"`
	OrganizationID string `json:"organization_id"`
	Email          string `json:"email"`
	jwt.RegisteredClaims
}

type registerRequest struct {
	OrganizationName string `json:"organization_name"`
	PropertyName     string `json:"property_name"`
	Timezone         string `json:"timezone"`
	Name             string `json:"name"`
	Email            string `json:"email"`
	Password         string `json:"password"`
}

type loginRequest struct {
	OrganizationID string `json:"organization_id"`
	Email          string `json:"email"`
	Password       string `json:"password"`
}

type userRecord struct {
	ID             string `json:"user_id"`
	OrganizationID string `json:"organization_id"`
	PropertyID     string `json:"property_id,omitempty"`
	Name           string `json:"name"`
	Email          string `json:"email"`
	Role           string `json:"role,omitempty"`
}

type authResponse struct {
	Token string     `json:"token"`
	User  userRecord `json:"user"`
}

type errorResponse struct {
	Error string `json:"error"`
}

func New(pool *pgxpool.Pool, secret string) *Service {
	s := &Service{
		pool:      pool,
		jwtSecret: []byte(secret),
	}
	s.accountActive = func(ctx context.Context, userID, orgID string) (bool, error) {
		var active bool
		err := pool.QueryRow(ctx, `
            SELECT EXISTS (
                SELECT 1
                FROM users u
                JOIN organizations o ON o.id = u.organization_id
                WHERE u.id = $1::uuid
                  AND u.organization_id = $2::uuid
                  AND u.status = 'active'
                  AND o.status = 'active'
            )
        `, userID, orgID).Scan(&active)
		return active, err
	}
	return s
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
         VALUES ($1::uuid, $2::uuid, $3::uuid, 'auth.register', 'user', $3::text, jsonb_build_object('email', $4::text))`,
		orgID, propertyID, userID, req.Email); err != nil {
		log.Printf("AUTH REGISTER AUDIT INSERT ERROR: %v", err)
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
	err = s.pool.QueryRow(ctx,
		`SELECT ur.property_id::text, r.name
         FROM user_roles ur
         JOIN roles r ON r.id = ur.role_id
         WHERE ur.user_id = $1::uuid
           AND r.organization_id = $2::uuid
         ORDER BY ur.created_at
         LIMIT 1`,
		userID, orgID,
	).Scan(&propertyID, &roleName)
	if err != nil {
		log.Printf("AUTH LOGIN ROLE LOOKUP ERROR: %v", err)
		writeError(w, http.StatusForbidden, "user has no valid role assignment")
		return
	}

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
	claims, ok := ClaimsFromContext(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "authentication required")
		return
	}

	ctx, cancel := context.WithTimeout(r.Context(), 5*time.Second)
	defer cancel()

	var displayName, email string
	err := s.pool.QueryRow(ctx, `
        SELECT display_name, email
        FROM users
        WHERE id = $1::uuid AND organization_id = $2::uuid
          AND status = 'active'
    `, claims.UserID, claims.OrganizationID).Scan(&displayName, &email)
	if err != nil {
		writeError(w, http.StatusServiceUnavailable, "could not load user profile")
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{
		"user_id":         claims.UserID,
		"organization_id": claims.OrganizationID,
		"name":            displayName,
		"email":           email,
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
