package main

import (
	"bytes"
	_ "embed"
	"html/template"
	"net/http"
	"os"
	"path/filepath"
	"strings"

	"github.com/yuin/goldmark"
	"github.com/yuin/goldmark/extension"
)

// Configure Goldmark with GitHub Flavored Markdown
var mdParser = goldmark.New(
	goldmark.WithExtensions(
		extension.GFM,
	),
)

//go:embed md_template.html
var mdTemplate string

//go:embed style.css
var styleCSS string

//go:embed index.html
var indexHTML string

//go:embed assignments.html
var assignmentsHTML string

var pageTmpl = template.Must(template.New("md_template.html").Parse(mdTemplate))

const authCookieName = "jta_auth"

func isAuthenticated(r *http.Request) bool {
	expectedHash := strings.TrimSpace(os.Getenv("AUTH_PASSWORD_HASH"))
	if expectedHash == "" {
		return false
	}

	cookie, err := r.Cookie(authCookieName)
	if err != nil {
		return false
	}

	providedHash := strings.TrimSpace(cookie.Value)
	return strings.EqualFold(providedHash, expectedHash)
}

func serveMarkdown(w http.ResponseWriter, r *http.Request) {
	// Prevent path traversal
	clean := filepath.Clean(r.URL.Path)
	path := filepath.Join(rootDir, strings.TrimPrefix(clean, "/"))

	mdBytes, err := os.ReadFile(path)
	if err != nil {
		http.NotFound(w, r)
		return
	}

	var buf bytes.Buffer
	if err := mdParser.Convert(mdBytes, &buf); err != nil {
		http.Error(w, "failed to render markdown", 500)
		return
	}

	w.Header().Set("Content-Type", "text/html; charset=utf-8")

	pageTmpl.Execute(w, map[string]template.HTML{
		"Content": template.HTML(buf.String()),
	})
}

var rootDir = "."

func main() {
	if envRootDir := os.Getenv("ROOT_DIR"); envRootDir != "" {
		rootDir = envRootDir
	}

	fs := http.FileServer(http.Dir(rootDir))
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path == "/" || r.URL.Path == "/index.html" {
			w.Header().Set("Content-Type", "text/html; charset=utf-8")
			w.Write([]byte(indexHTML))
			return
		}

		if r.URL.Path == "/style.css" {
			w.Header().Set("Content-Type", "text/css; charset=utf-8")
			w.Write([]byte(styleCSS))
			return
		}

		if !isAuthenticated(r) {
			http.Error(w, "unauthorized", http.StatusUnauthorized)
			return
		}

		if r.URL.Path == "/assignments" || r.URL.Path == "/assignments.html" {
			w.Header().Set("Content-Type", "text/html; charset=utf-8")
			w.Write([]byte(assignmentsHTML))
			return
		}

		// Intercept markdown files
		if strings.HasSuffix(r.URL.Path, ".md") {
			serveMarkdown(w, r)
			return
		}

		// Otherwise serve normally
		fs.ServeHTTP(w, r)
	})

	http.ListenAndServe(":"+port, nil)
}
