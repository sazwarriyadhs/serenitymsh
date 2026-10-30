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
        // Fallback hanya untuk lokal
        dbURL = "postgres://serenity:Serenitydatabase2026@localhost:5434/serenity?sslmode=disable"
    }

    // Mencegah penggunaan database lokal jika di Railway
    if os.Getenv("RAILWAY_ENVIRONMENT") != "" && dbURL == "postgres://serenity:Serenitydatabase2026@localhost:5434/serenity?sslmode=disable" {
        log.Fatal("CRITICAL: DATABASE_URL belum diatur di Railway Variables! Harap atur DATABASE_URL ke URL Supabase.")
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
