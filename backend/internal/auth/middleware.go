package auth

import (
	"context"
	"errors"
	"net/http"
	"strings"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

type claimsContextKey struct{}

func ClaimsFromContext(ctx context.Context) (*Claims, bool) {
	claims, ok := ctx.Value(claimsContextKey{}).(*Claims)
	return claims, ok && claims != nil
}

// RequireAuth validates the JWT and checks that the user and organization remain active.
func (s *Service) RequireAuth(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		header := strings.TrimSpace(r.Header.Get("Authorization"))
		parts := strings.SplitN(header, " ", 2)
		if len(parts) != 2 ||
			!strings.EqualFold(parts[0], "Bearer") ||
			strings.TrimSpace(parts[1]) == "" {
			writeError(w, http.StatusUnauthorized, "bearer token required")
			return
		}

		claims := &Claims{}
		token, err := jwt.ParseWithClaims(
			strings.TrimSpace(parts[1]),
			claims,
			func(token *jwt.Token) (any, error) {
				if token.Method != jwt.SigningMethodHS256 {
					return nil, errors.New("unexpected signing method")
				}
				return s.jwtSecret, nil
			},
			jwt.WithIssuer("serenity-hms"),
		)

		if err != nil || token == nil || !token.Valid ||
			claims.UserID == "" || claims.OrganizationID == "" ||
			claims.Subject != claims.UserID {
			writeError(w, http.StatusUnauthorized, "invalid or expired token")
			return
		}

		if s.accountActive == nil {
			writeError(w, http.StatusServiceUnavailable, "account verification unavailable")
			return
		}

		ctx, cancel := context.WithTimeout(r.Context(), 5*time.Second)
		defer cancel()

		active, err := s.accountActive(ctx, claims.UserID, claims.OrganizationID)
		if err != nil {
			writeError(w, http.StatusServiceUnavailable, "could not verify account status")
			return
		}
		if !active {
			writeError(w, http.StatusUnauthorized, "user or organization is unavailable")
			return
		}

		ctxWithClaims := context.WithValue(r.Context(), claimsContextKey{}, claims)
		next.ServeHTTP(w, r.WithContext(ctxWithClaims))
	})
}
