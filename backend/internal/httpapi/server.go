package httpapi

import (
    "log"
    "net/http"

    "github.com/jackc/pgx/v5/pgxpool"
)

func enableCORS(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Access-Control-Allow-Origin", "*")
        w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
        w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

        if r.Method == "OPTIONS" {
            w.WriteHeader(http.StatusOK)
            return
        }
        next.ServeHTTP(w, r)
    })
}

func New(db *pgxpool.Pool, jwtSecret string) http.Handler {
    mux := http.NewServeMux()

    // Daftarkan rute dengan mengirimkan koneksi database (db)
    mux.HandleFunc("/api/dashboard", HandleDashboard(db))
    mux.HandleFunc("/api/inquiries", HandleInquiry(db))

    mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        w.WriteHeader(http.StatusOK)
        w.Write([]byte("Serenity HMS API is running..."))
    })

    handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        log.Printf("[API] %s %s", r.Method, r.URL.Path)
        mux.ServeHTTP(w, r)
    })

    return enableCORS(handler)
}
