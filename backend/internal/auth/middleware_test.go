package auth

import (
	"context"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"
)

const testJWTSecret = "01234567890123456789012345678901"
const testUserID = "eb7c21fe-534c-457b-9a17-fef5bb9a441a"
const testOrgID = "0e039251-8f68-4abf-b536-67100fae8b97"

func testService() *Service {
	s := New(nil, testJWTSecret)
	s.accountActive = func(context.Context, string, string) (bool, error) {
		return true, nil
	}
	return s
}

func testToken(t *testing.T, s *Service) string {
	t.Helper()
	token, err := s.issueToken(testUserID, testOrgID, "admin-demo@serenity.local")
	if err != nil {
		t.Fatalf("issue token: %v", err)
	}
	return token
}

func runProtected(s *Service, token string) *httptest.ResponseRecorder {
	handler := s.RequireAuth(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		claims, ok := ClaimsFromContext(r.Context())
		if !ok {
			http.Error(w, "claims missing", http.StatusInternalServerError)
			return
		}
		if claims.UserID != testUserID || claims.OrganizationID != testOrgID {
			http.Error(w, "unexpected claims", http.StatusInternalServerError)
			return
		}
		w.WriteHeader(http.StatusNoContent)
	}))

	req := httptest.NewRequest(http.MethodGet, "/protected", nil)
	if token != "" {
		req.Header.Set("Authorization", "Bearer "+token)
	}
	rec := httptest.NewRecorder()
	handler.ServeHTTP(rec, req)
	return rec
}

func TestRequireAuthRejectsMissingToken(t *testing.T) {
	rec := runProtected(testService(), "")
	if rec.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401, got %d", rec.Code)
	}
}

func TestRequireAuthRejectsInvalidToken(t *testing.T) {
	rec := runProtected(testService(), "invalid.token.value")
	if rec.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401, got %d", rec.Code)
	}
}

func TestRequireAuthRejectsInactiveAccountOrOrganization(t *testing.T) {
	s := testService()
	s.accountActive = func(context.Context, string, string) (bool, error) {
		return false, nil
	}
	rec := runProtected(s, testToken(t, s))
	if rec.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401, got %d", rec.Code)
	}
}

func TestRequireAuthReturns503WhenAccountCheckFails(t *testing.T) {
	s := testService()
	s.accountActive = func(context.Context, string, string) (bool, error) {
		return false, errors.New("database unavailable")
	}
	rec := runProtected(s, testToken(t, s))
	if rec.Code != http.StatusServiceUnavailable {
		t.Fatalf("expected 503, got %d", rec.Code)
	}
}

func TestRequireAuthReturns503WhenVerifierMissing(t *testing.T) {
	s := testService()
	s.accountActive = nil
	rec := runProtected(s, testToken(t, s))
	if rec.Code != http.StatusServiceUnavailable {
		t.Fatalf("expected 503, got %d", rec.Code)
	}
}

func TestRequireAuthAcceptsValidActiveAccount(t *testing.T) {
	s := testService()
	rec := runProtected(s, testToken(t, s))
	if rec.Code != http.StatusNoContent {
		t.Fatalf("expected 204, got %d: %s", rec.Code, rec.Body.String())
	}
}
