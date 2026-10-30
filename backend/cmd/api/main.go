package main

import (
    "context"
    "fmt"
    "log"
    "net/http"
    "os"
    "serenity-hms/backend/internal/config"
    "serenity-hms/backend/internal/database"
    "serenity-hms/backend/internal/httpapi"
)

func main() {
    // 1. Load config
    cfg := config.Load()

    // 2. Koneksi ke database
    ctx := context.Background()
    dbPool, err := database.Open(ctx, cfg.DatabaseURL)
    if err != nil {
        log.Fatalf("Gagal koneksi ke database: %v", err)
    }
    defer dbPool.Close()

    // 3. Setup Router/API
    handler := httpapi.New(dbPool, cfg.JWTSecret)

    // 4. Tentukan Port (Prioritaskan PORT dari Railway)
    port := os.Getenv("PORT")
    if port == "" {
        port = cfg.Port // Fallback ke config lokal (8091)
    }

    // Wajib bind ke "0.0.0.0" agar bisa diakses dari luar container Railway
    addr := fmt.Sprintf("0.0.0.0:%s", port)
    log.Printf("Server berjalan di http://%s", addr)
    
    if err := http.ListenAndServe(addr, handler); err != nil {
        log.Fatalf("Server gagal berjalan: %v", err)
    }
}
