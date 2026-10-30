package main

import (
    "fmt"
    "log"
    "net/http"
    "serenity-hms/backend/internal/config"
    "serenity-hms/backend/internal/httpapi"
    "serenity-hms/backend/internal/database"
)

func main() {
    // 1. Load config
    cfg := config.Load()

    // 2. Koneksi ke database
    dbPool, err := database.Connect(cfg.DatabaseURL)
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
