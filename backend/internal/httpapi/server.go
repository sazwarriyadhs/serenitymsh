package httpapi

import (
    "log"
    "net/http"

    "github.com/jackc/pgx/v5/pgxpool"
)

func New(db *pgxpool.Pool, jwtSecret string) http.Handler {
    mux := http.NewServeMux()

    // Daftarkan rute publik (tanpa login) untuk sementara
    mux.HandleFunc("/api/dashboard", HandleDashboard)
    mux.HandleFunc("/api/inquiries", HandleInquiry)

    mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        w.WriteHeader(http.StatusOK)
        w.Write([]byte("Serenity HMS API is running..."))
    })

    // (Catatan: db dan jwtSecret nanti digunakan untuk auth & DB)
    // (Untuk sementara kita biarkan sebagai placeholder agar compile)

    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        log.Printf("[API] %s %s", r.Method, r.URL.Path)
        mux.ServeHTTP(w, r)
    })
}