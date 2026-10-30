package main

import (
	"context"
	"errors"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"serenity-hms/backend/internal/config"
	"serenity-hms/backend/internal/database"
	"serenity-hms/backend/internal/httpapi"
)

func main() {
	if err := run(); err != nil {
		log.Fatal(err)
	}
}

func run() error {
	cfg, err := config.Load()
	if err != nil {
		return err
	}
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	pool, err := database.Open(ctx, cfg.DatabaseURL)
	if err != nil {
		return err
	}
	defer pool.Close()

	command := "serve"
	if len(os.Args) > 1 {
		command = os.Args[1]
	}

	switch command {
	case "migrate":
		return database.ApplyMigrations(ctx, pool)
	case "serve":
		server := &http.Server{
			Addr:              ":" + cfg.APIPort,
			Handler:           httpapi.New(pool, cfg.JWTSecret),
			ReadHeaderTimeout: 5 * time.Second,
		}
		errCh := make(chan error, 1)
		go func() {
			log.Printf("Serenity API listening on :%s", cfg.APIPort)
			errCh <- server.ListenAndServe()
		}()
		select {
		case err := <-errCh:
			if errors.Is(err, http.ErrServerClosed) {
				return nil
			}
			return fmt.Errorf("HTTP server: %w", err)
		case <-ctx.Done():
			shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
			defer cancel()
			return server.Shutdown(shutdownCtx)
		}
	default:
		return fmt.Errorf("unknown command %q; use serve or migrate", command)
	}
}
