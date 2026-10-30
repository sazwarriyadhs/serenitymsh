package config

import (
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
        // Fallback khusus untuk lokal (Windows)
        dbURL = "postgres://serenity:Serenitydatabase2026@localhost:5434/serenity?sslmode=disable"
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
