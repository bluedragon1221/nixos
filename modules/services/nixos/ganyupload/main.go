package main

import (
	_ "embed"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strings"
)

//go:embed README
var readme string

var uploadDir = "."

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

	if r.Method != http.MethodPut {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}

	// Extract filename from URL path, preventing path traversal
	filename := strings.TrimPrefix(r.URL.Path, "/")
	if filename == "" {
		http.Error(w, "filename required", http.StatusBadRequest)
		return
	}

	// Prevent path traversal
	filename = filepath.Clean(filename)
	if strings.HasPrefix(filename, "..") {
		http.Error(w, "invalid filename", http.StatusBadRequest)
		return
	}

	fullPath := filepath.Join(uploadDir, filename)

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
