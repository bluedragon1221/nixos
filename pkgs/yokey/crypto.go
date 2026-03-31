package main

import (
	"crypto"
	"crypto/ed25519"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/pem"
	"io"
	"strings"

	"golang.org/x/crypto/curve25519"
	"golang.org/x/crypto/hkdf"
	"golang.org/x/crypto/ssh"
	"pault.ag/go/sshsig"
)

const sshsigContext = "sshsig-key-v1"

func deriveKey(master []byte, info string, length int) []byte {
	h := hkdf.New(sha256.New, master, []byte("fixed-salt"), []byte(info))
	out := make([]byte, length)
	if _, err := io.ReadFull(h, out); err != nil {
		panic(err)
	}
	return out
}

func buildInfo(baseInfo, context string) string {
	trimmed := strings.TrimSpace(context)
	if trimmed == "" {
		return baseInfo
	}

	return baseInfo + ":" + trimmed
}

func deriveEd25519(master []byte, context string) (string, []byte) {
	seed := deriveKey(master, buildInfo("ed25519-key-v1", context), 32)
	priv := ed25519.NewKeyFromSeed(seed)
	pub := priv.Public().(ed25519.PublicKey)

	sshPub, err := ssh.NewPublicKey(pub)
	if err != nil {
		panic(err)
	}

	privBlock, err := ssh.MarshalPrivateKey(priv, "")
	if err != nil {
		panic(err)
	}

	return string(ssh.MarshalAuthorizedKey(sshPub)), pem.EncodeToMemory(privBlock)
}

func deriveWireGuard(master []byte, context string) (string, string) {
	priv := deriveKey(master, buildInfo("wireguard-key-v1", context), 32)
	pub, _ := curve25519.X25519(priv, curve25519.Basepoint)

	return base64.StdEncoding.EncodeToString(pub), base64.StdEncoding.EncodeToString(priv)
}

const passwordCharset = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@$%^&*"
const passwordLength = 14

func derivePassword(master []byte, seed string) string {
	return derivePasswordWithContext(master, seed, "")
}

func derivePasswordWithContext(master []byte, seed, context string) string {
	info := buildInfo("password-v1:"+seed, context)
	stream := hkdf.New(sha256.New, master, []byte("my-fixed-salt"), []byte(info))
	out := make([]byte, 0, passwordLength)
	buf := make([]byte, 64)
	maxMultiple := byte(256 / len(passwordCharset) * len(passwordCharset))

	for len(out) < passwordLength {
		if _, err := io.ReadFull(stream, buf); err != nil {
			panic(err)
		}

		for _, b := range buf {
			if b >= maxMultiple {
				continue
			}

			out = append(out, passwordCharset[int(b)%len(passwordCharset)])
			if len(out) == passwordLength {
				break
			}
		}
	}

	return string(out)
}

func deriveSSHSigSigner(master []byte) ssh.Signer {
	_, privPem := deriveEd25519(master, sshsigContext)
	rawPriv, err := ssh.ParseRawPrivateKey(privPem)
	if err != nil {
		panic(err)
	}

	signer, err := ssh.NewSignerFromKey(rawPriv)
	if err != nil {
		panic(err)
	}

	return signer
}

func signSSHSig(master []byte, namespace string, message []byte) []byte {
	signer := deriveSSHSigSigner(master)
	h := crypto.SHA512.New()
	if _, err := h.Write(message); err != nil {
		panic(err)
	}

	sig, err := sshsig.Sign(rand.Reader, signer, []byte(namespace), sshsig.HashAlgoSHA512, h.Sum(nil))
	if err != nil {
		panic(err)
	}

	return sig
}

func verifySSHSig(master []byte, namespace string, message, signature []byte) error {
	signer := deriveSSHSigSigner(master)
	pub := signer.PublicKey()

	parsedSig, err := sshsig.ParseSignature(signature)
	if err != nil {
		return err
	}

	h := crypto.SHA512.New()
	if _, err := h.Write(message); err != nil {
		return err
	}

	return sshsig.Verify(pub, []byte(namespace), sshsig.HashAlgoSHA512, h.Sum(nil), parsedSig)
}

func generateMasterKeyBytes() []byte {
	key := make([]byte, 32)
	rand.Read(key)

	return key
}
