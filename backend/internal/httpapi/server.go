package httpapi

import (
	"log"
	"net/http"

	"github.com/jackc/pgx/v5/pgxpool"
)

// Middleware untuk mengizinkan akses dari Frontend (Vercel)
func enableCORS(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Izinkan semua domain (termasuk localhost dan Vercel)
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		// Tangani request preflight (OPTIONS) dari browser
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)
	})
}

func New(db *pgxpool.Pool, jwtSecret string) http.Handler {
	mux := http.NewServeMux()

	// Daftarkan rute publik
	mux.HandleFunc("/api/dashboard", HandleDashboard)
	mux.HandleFunc("/api/inquiries", HandleInquiry)

	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("Serenity HMS API is running..."))
	})

	// Bungkus mux dengan logger dan CORS
	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		log.Printf("[API] %s %s", r.Method, r.URL.Path)
		mux.ServeHTTP(w, r)
	})

	return enableCORS(handler)
}
