package main

import (
	_ "embed"
	"fmt"
	"html"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"sort"
	"strings"
)

//go:embed README
var readme string

var uploadDir = "."

// cleanPath safely cleans and validates a path to prevent traversal attacks
func cleanPath(filename string) (string, error) {
	// Remove leading slash
	filename = strings.TrimPrefix(filename, "/")
	if filename == "" {
		return "", nil
	}

	// Clean the path
	filename = filepath.Clean(filename)

	// Reject if it tries to go up
	if strings.HasPrefix(filename, "..") || strings.Contains(filename, "/../") {
		return "", fmt.Errorf("invalid filename: path traversal not allowed")
	}

	return filename, nil
}

// isPathSafe checks that the resolved fullPath stays within uploadDir
func isPathSafe(uploadDir, fullPath string) bool {
	// Resolve both paths to absolute to catch symlink attacks
	absUploadDir, err := filepath.Abs(uploadDir)
	if err != nil {
		return false
	}
	absFullPath, err := filepath.Abs(fullPath)
	if err != nil {
		return false
	}

	// Ensure the resolved path starts with uploadDir
	return strings.HasPrefix(absFullPath, absUploadDir+string(filepath.Separator)) ||
		absFullPath == absUploadDir
}

func handleRoot(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}

	w.Header().Set("Content-Type", "text/plain; charset=utf-8")
	w.Write([]byte(readme))
}

func handleUpload(w http.ResponseWriter, r *http.Request) {
	// Show README on GET /
	if r.Method == http.MethodGet && r.URL.Path == "/" {
		handleRoot(w, r)
		return
	}

	// Handle GET requests for downloads and directory listing
	if r.Method == http.MethodGet {
		handleDownload(w, r)
		return
	}

	if r.Method != http.MethodPut {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}

	// Extract filename from URL path, preventing path traversal
	filename, err := cleanPath(r.URL.Path)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	if filename == "" {
		http.Error(w, "filename required", http.StatusBadRequest)
		return
	}

	fullPath := filepath.Join(uploadDir, filename)

	// Verify the path is safe
	if !isPathSafe(uploadDir, fullPath) {
		http.Error(w, "invalid path", http.StatusBadRequest)
		return
	}

	// Ensure the directory exists
	dir := filepath.Dir(fullPath)
	if err := os.MkdirAll(dir, 0755); err != nil {
		log.Printf("failed to create directory: %v", err)
		http.Error(w, "internal server error", http.StatusInternalServerError)
		return
	}

	// Create the file
	f, err := os.Create(fullPath)
	if err != nil {
		log.Printf("failed to create file: %v", err)
		http.Error(w, "internal server error", http.StatusInternalServerError)
		return
	}
	defer f.Close()

	// Copy request body to file
	written, err := io.Copy(f, r.Body)
	if err != nil {
		log.Printf("failed to write file: %v", err)
		http.Error(w, "internal server error", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "text/plain; charset=utf-8")
	w.WriteHeader(http.StatusCreated)
	w.Write([]byte("ok\n"))

	log.Printf("uploaded %s (%d bytes)", filename, written)
}

func handleDownload(w http.ResponseWriter, r *http.Request) {
	// Extract filename from URL path
	filename, err := cleanPath(r.URL.Path)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	fullPath := filepath.Join(uploadDir, filename)

	// Verify the path is safe
	if !isPathSafe(uploadDir, fullPath) {
		http.Error(w, "invalid path", http.StatusBadRequest)
		return
	}

	fileInfo, err := os.Stat(fullPath)
	if err != nil {
		if os.IsNotExist(err) {
			http.Error(w, "not found", http.StatusNotFound)
		} else {
			log.Printf("failed to stat: %v", err)
			http.Error(w, "internal server error", http.StatusInternalServerError)
		}
		return
	}

	// If it's a directory, list its contents
	if fileInfo.IsDir() {
		handleDirList(w, r, uploadDir, filename, fullPath)
		return
	}

	// Serve the file
	http.ServeFile(w, r, fullPath)
}

func handleDirList(w http.ResponseWriter, r *http.Request, uploadDir, relPath, fullPath string) {
	entries, err := os.ReadDir(fullPath)
	if err != nil {
		log.Printf("failed to read directory: %v", err)
		http.Error(w, "internal server error", http.StatusInternalServerError)
		return
	}

	// Sort entries by name
	sort.Slice(entries, func(i, j int) bool {
		return entries[i].Name() < entries[j].Name()
	})

	// Build breadcrumb navigation
	pathParts := strings.Split(strings.Trim(relPath, "/"), "/")
	if relPath == "" {
		pathParts = []string{}
	}

	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	w.WriteHeader(http.StatusOK)

	fmt.Fprintf(w, `<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Directory: %s</title>
    <style>
        body { font-family: monospace; margin: 2rem; }
        h1 { margin-bottom: 0.5rem; }
        .breadcrumb { margin-bottom: 2rem; font-size: 0.9rem; }
        .breadcrumb a { text-decoration: none; color: #0066cc; }
        .breadcrumb a:hover { text-decoration: underline; }
        table { border-collapse: collapse; width: 100%%; }
        td { padding: 0.5rem; border-bottom: 1px solid #ccc; }
        td:first-child { text-align: left; }
        td:last-child { text-align: right; color: #666; }
        a { text-decoration: none; color: #0066cc; }
        a:hover { text-decoration: underline; }
        .directory { color: #0066cc; font-weight: bold; }
    </style>
</head>
<body>
    <h1>Directory: %s</h1>
`, html.EscapeString(relPath), html.EscapeString(relPath))

	// Breadcrumb navigation
	fmt.Fprint(w, `    <div class="breadcrumb">`)
	fmt.Fprintf(w, `<a href="/">home</a>`)
	if len(pathParts) > 0 {
		accumulated := ""
		for _, part := range pathParts {
			accumulated = accumulated + "/" + part
			fmt.Fprintf(w, ` / <a href="%s">%s</a>`, html.EscapeString(accumulated), html.EscapeString(part))
		}
	}
	fmt.Fprint(w, `</div>`)

	// Directory listing
	fmt.Fprint(w, `    <table>
`)
	for _, entry := range entries {
		name := entry.Name()
		safeName := html.EscapeString(name)

		if entry.IsDir() {
			// For directories, add trailing slash to the link
			linkPath := relPath + "/" + name
			if relPath == "" {
				linkPath = "/" + name
			}
			linkPath = strings.TrimPrefix(linkPath, "/")
			fmt.Fprintf(w, `        <tr><td><a href="/%s" class="directory">%s/</a></td><td>-</td></tr>
`, html.EscapeString(linkPath), safeName)
		} else {
			info, _ := entry.Info()
			linkPath := relPath + "/" + name
			if relPath == "" {
				linkPath = "/" + name
			}
			linkPath = strings.TrimPrefix(linkPath, "/")
			size := formatSize(info.Size())
			fmt.Fprintf(w, `        <tr><td><a href="/%s">%s</a></td><td>%s</td></tr>
`, html.EscapeString(linkPath), safeName, size)
		}
	}
	fmt.Fprint(w, `    </table>
</body>
</html>
`)
}

func formatSize(bytes int64) string {
	const (
		KB = 1024
		MB = KB * 1024
		GB = MB * 1024
	)

	switch {
	case bytes < KB:
		return fmt.Sprintf("%d B", bytes)
	case bytes < MB:
		return fmt.Sprintf("%.1f KB", float64(bytes)/KB)
	case bytes < GB:
		return fmt.Sprintf("%.1f MB", float64(bytes)/MB)
	default:
		return fmt.Sprintf("%.1f GB", float64(bytes)/GB)
	}
}

func main() {
	if envUploadDir := os.Getenv("UPLOAD_DIR"); envUploadDir != "" {
		uploadDir = envUploadDir
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	http.HandleFunc("/", handleUpload)

	log.Printf("starting ganyupload on port %s, upload directory: %s", port, uploadDir)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatalf("server error: %v", err)
	}
}
