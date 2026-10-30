package migrations

import "embed"

// FS contains the versioned SQL migration files.
//
//go:embed *.sql
var FS embed.FS
