package config

import (
    "log"
    "os"
)

type Config struct {
    DatabaseURL string
    JWTSecret   string
    Port        string
}

func Load() *Config {
    dbURL := os.Getenv("DATABASE_URL")
    if dbURL == "" {
        // Fallback khusus lokal
        dbURL = "postgres://serenity:Serenitydatabase2026@localhost:5434/serenity?sslmode=disable"
    }

    // Jika di Railway dan URL masih localhost, matikan aplikasi dengan error jelas
    if os.Getenv("RAILWAY_ENVIRONMENT") != "" && dbURL == "postgres://serenity:Serenitydatabase2026@localhost:5434/serenity?sslmode=disable" {
        log.Fatal("CRITICAL: DATABASE_URL belum diatur di Railway Variables! Harap atur ke URL Supabase.")
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
