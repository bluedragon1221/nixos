package main

import (
	"bytes"
	"crypto/ed25519"
	"encoding/base64"
	"encoding/hex"
	"strings"
	"testing"

	"golang.org/x/crypto/curve25519"
	"golang.org/x/crypto/ssh"
)

const testMasterHex = "95609277cb88af80a624df3cb8bb130d49ac62707d16e925762dadbec32a1d45"

func testMasterKey(t *testing.T) []byte {
	t.Helper()

	master, err := hex.DecodeString(testMasterHex)
	if err != nil {
		t.Fatalf("decode master key: %v", err)
	}

	return master
}

func parseEd25519PrivateKey(t *testing.T, pemBytes []byte) ed25519.PrivateKey {
	t.Helper()

	rawPriv, err := ssh.ParseRawPrivateKey(pemBytes)
	if err != nil {
		t.Fatalf("parse private key: %v", err)
	}

	switch key := rawPriv.(type) {
	case ed25519.PrivateKey:
		return key
	case *ed25519.PrivateKey:
		return *key
	default:
		t.Fatalf("unexpected private key type: %T", rawPriv)
		return nil
	}
}

func TestBuildInfo(t *testing.T) {
	if got := buildInfo("ed25519-key-v1", ""); got != "ed25519-key-v1" {
		t.Fatalf("empty context mismatch: %q", got)
	}

	if got := buildInfo("ed25519-key-v1", "   "); got != "ed25519-key-v1" {
		t.Fatalf("whitespace context mismatch: %q", got)
	}

	if got := buildInfo("ed25519-key-v1", "host:ganymede"); got != "ed25519-key-v1:host:ganymede" {
		t.Fatalf("context append mismatch: %q", got)
	}
}

func TestDeriveEd25519DeterministicAndScoped(t *testing.T) {
	master := testMasterKey(t)

	pubA1, privA1 := deriveEd25519(master, "host:ganymede")
	pubA2, privA2 := deriveEd25519(master, "host:ganymede")
	if pubA1 != pubA2 {
		t.Fatalf("public key should be deterministic")
	}

	edPrivA1 := parseEd25519PrivateKey(t, privA1)
	edPrivA2 := parseEd25519PrivateKey(t, privA2)

	if !bytes.Equal(edPrivA1, edPrivA2) {
		t.Fatalf("private key material should be deterministic")
	}

	pubB, privB := deriveEd25519(master, "host:mercury")
	if pubA1 == pubB {
		t.Fatalf("public keys should differ across contexts")
	}

	edPrivB := parseEd25519PrivateKey(t, privB)

	if bytes.Equal(edPrivA1, edPrivB) {
		t.Fatalf("private key material should differ across contexts")
	}

	if !strings.HasPrefix(pubA1, "ssh-ed25519 ") {
		t.Fatalf("unexpected public key format: %q", pubA1)
	}

	if len(edPrivA1) != ed25519.PrivateKeySize {
		t.Fatalf("unexpected private key size: %d", len(edPrivA1))
	}
}

func TestDeriveWireGuardDeterministicAndScoped(t *testing.T) {
	master := testMasterKey(t)

	pubA1, privA1 := deriveWireGuard(master, "vpn:home")
	pubA2, privA2 := deriveWireGuard(master, "vpn:home")
	if pubA1 != pubA2 || privA1 != privA2 {
		t.Fatalf("wireguard keys should be deterministic")
	}

	pubB, privB := deriveWireGuard(master, "vpn:office")
	if pubA1 == pubB || privA1 == privB {
		t.Fatalf("wireguard keys should differ across contexts")
	}

	privBytes, err := base64.StdEncoding.DecodeString(privA1)
	if err != nil {
		t.Fatalf("decode private key: %v", err)
	}
	if len(privBytes) != 32 {
		t.Fatalf("private key should decode to 32 bytes, got %d", len(privBytes))
	}

	pubBytes, err := base64.StdEncoding.DecodeString(pubA1)
	if err != nil {
		t.Fatalf("decode public key: %v", err)
	}
	if len(pubBytes) != 32 {
		t.Fatalf("public key should decode to 32 bytes, got %d", len(pubBytes))
	}

	recomputedPub, err := curve25519.X25519(privBytes, curve25519.Basepoint)
	if err != nil {
		t.Fatalf("recompute public key: %v", err)
	}
	if !bytes.Equal(pubBytes, recomputedPub) {
		t.Fatalf("public key does not match private key")
	}
}

func TestDerivePasswordDeterministicCharsetAndContext(t *testing.T) {
	master := testMasterKey(t)

	p1 := derivePassword(master, "forgejo")
	p2 := derivePassword(master, "forgejo")
	if p1 != p2 {
		t.Fatalf("password should be deterministic")
	}

	if len(p1) != passwordLength {
		t.Fatalf("password length mismatch: got %d want %d", len(p1), passwordLength)
	}

	for _, ch := range p1 {
		if !strings.ContainsRune(passwordCharset, ch) {
			t.Fatalf("password contains invalid character: %q", ch)
		}
	}

	pCtxA := derivePasswordWithContext(master, "forgejo", "host:ganymede")
	pCtxB := derivePasswordWithContext(master, "forgejo", "host:mercury")
	if pCtxA == pCtxB {
		t.Fatalf("context should change derived password")
	}

	pEmptyCtx := derivePasswordWithContext(master, "forgejo", "")
	if p1 != pEmptyCtx {
		t.Fatalf("empty context should match default password derivation")
	}
}

func TestGenerateMasterKeyBytesLength(t *testing.T) {
	key := generateMasterKeyBytes()
	if len(key) != 32 {
		t.Fatalf("master key should be 32 bytes, got %d", len(key))
	}

	allZero := true
	for _, b := range key {
		if b != 0 {
			allZero = false
			break
		}
	}
	if allZero {
		t.Fatalf("generated master key should not be all zeros")
	}
}
