package httpapi

import (
    "context"
    "encoding/json"
    "log"
    "net/http"

    "github.com/jackc/pgx/v5/pgxpool"
)

// ==========================================
// DASHBOARD HANDLER
// ==========================================
type DashboardResponse struct {
    PropertyName string json:"property_name"
    TotalRooms   int    json:"total_rooms"
    Occupancy    int    json:"occupancy_percentage"
    ActiveEvents int    json:"active_events"
}

func HandleDashboard(db *pgxpool.Pool) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        setCORS(w)
        if r.Method == "OPTIONS" {
            w.WriteHeader(http.StatusOK)
            return
        }

        data := DashboardResponse{
            PropertyName: "IPB Convention Hotel",
            TotalRooms:   150,
            Occupancy:    78,
            ActiveEvents: 3,
        }
        writeJSON(w, http.StatusOK, data)
    }
}

// ==========================================
// INQUIRY HANDLER
// ==========================================
type InquiryRequest struct {
    GuestName   string json:"guest_name"
    Email       string json:"email"
    InquiryType string json:"inquiry_type"
    Notes       string json:"notes"
}

type InquiryResponse struct {
    Status  string json:"status"
    Message string json:"message"
}

func HandleInquiry(db *pgxpool.Pool) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        setCORS(w)
        if r.Method == "OPTIONS" {
            w.WriteHeader(http.StatusOK)
            return
        }

        if r.Method != "POST" {
            writeJSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "Method not allowed"})
            return
        }

        var req InquiryRequest
        if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
            writeJSON(w, http.StatusBadRequest, map[string]string{"error": "Invalid JSON"})
            return
        }

        if req.GuestName == "" || req.Email == "" {
            writeJSON(w, http.StatusBadRequest, map[string]string{"error": "Name and Email required"})
            return
        }

        // SIMPAN KE DATABASE SUPABASE
        ctx := context.Background()
        query := INSERT INTO inquiries (name, email, interested_in, message) VALUES (, , , )
        _, err := db.Exec(ctx, query, req.GuestName, req.Email, req.InquiryType, req.Notes)
        
        if err != nil {
            log.Printf("[ERROR] Gagal menyimpan inquiry: %v", err)
            writeJSON(w, http.StatusInternalServerError, map[string]string{"error": "Gagal menyimpan ke database"})
            return
        }

        log.Printf("[NEW INQUIRY] %s (%s) - Berhasil disimpan ke database", req.GuestName, req.Email)
        writeJSON(w, http.StatusOK, InquiryResponse{Status: "success", Message: "Inquiry received"})
    }
}

// ==========================================
// UTILITIES
// ==========================================
func setCORS(w http.ResponseWriter) {
    w.Header().Set("Access-Control-Allow-Origin", "*")
    w.Header().Set("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
    w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
}

func writeJSON(w http.ResponseWriter, status int, data interface{}) {
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(status)
    json.NewEncoder(w).Encode(data)
}
