package config

import (
    "log"
    "os"
    "strings"
)

type Config struct {
    DatabaseURL string
    JWTSecret   string
    Port        string
}

func Load() *Config {
    dbURL := os.Getenv("DATABASE_URL")
    
    // Jika DATABASE_URL kosong ATAU berisi localhost, kita anggap error (kecuali di lokal)
    if dbURL == "" || strings.Contains(dbURL, "localhost") || strings.Contains(dbURL, "127.0.0.1") {
        // Cek apakah kita sedang berjalan di Railway (biasanya Railway punya env PORT yang bukan 8091)
        if os.Getenv("PORT") != "" && os.Getenv("PORT") != "8091" {
            log.Fatal("CRITICAL: DATABASE_URL tidak valid! Anda menjalankan di Cloud/Railway, tetapi DATABASE_URL mengarah ke localhost. Harap atur variabel DATABASE_URL ke URL Supabase.")
        }
        
        // Fallback untuk lokal
        if dbURL == "" {
            dbURL = "postgres://serenity:Serenitydatabase2026@localhost:5434/serenity?sslmode=disable"
        }
    }

    jwtSecret := os.Getenv("JWT_SECRET")
    if jwtSecret == "" {
        jwtSecret = "rahasia_lokal_123"
    }

    port := os.Getenv("PORT")
    if port == "" {
        port = "8091"
    }

    return &Config{
        DatabaseURL: dbURL,
        JWTSecret:   jwtSecret,
        Port:        port,
    }
}
