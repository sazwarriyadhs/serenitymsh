package main

import (
    "context"
    "fmt"
    "log"
    "net/http"
    "serenity-hms/backend/internal/config"
    "serenity-hms/backend/internal/database"
    "serenity-hms/backend/internal/httpapi"
)

func main() {
    // 1. Load config
    cfg := config.Load()

    // 2. Koneksi ke database (menggunakan fungsi Open dan context.Background())
    ctx := context.Background()
    dbPool, err := database.Open(ctx, cfg.DatabaseURL)
    if err != nil {
        log.Fatalf("Gagal koneksi ke database: %v", err)
    }
    defer dbPool.Close()

    // 3. Setup Router/API
    handler := httpapi.New(dbPool, cfg.JWTSecret)

    // 4. Jalankan Server
    addr := fmt.Sprintf(":%s", cfg.Port)
    log.Printf("Server berjalan di http://localhost%s", addr)
    
    if err := http.ListenAndServe(addr, handler); err != nil {
        log.Fatalf("Server gagal berjalan: %v", err)
    }
}
