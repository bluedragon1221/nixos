package main

import (
	"bufio"
	"bytes"
	"encoding/base64"
	"encoding/hex"
	"encoding/pem"
	"fmt"
	"io"
	"os"
	"strings"

	"golang.org/x/crypto/ssh"
)

func readMasterKey() []byte {
	reader := bufio.NewReader(os.Stdin)
	input, err := reader.ReadString('\n')
	if err != nil && err != io.EOF {
		panic(err)
	}
	input = strings.TrimSpace(input)
	if decoded, err := hex.DecodeString(input); err == nil {
		return decoded
	}
	return []byte(input)
}

func formatSignedMessage(message string, signature []byte) string {
	var out bytes.Buffer

	out.WriteString("-----BEGIN SSH SIGNED MESSAGE-----\n")
	out.WriteString(message)
	if !strings.HasSuffix(message, "\n") {
		out.WriteString("\n")
	}

	sigBlock := pem.EncodeToMemory(&pem.Block{Type: "SSH SIGNATURE", Bytes: signature})
	out.Write(sigBlock)

	return out.String()
}

func main() {
	if len(os.Args) < 2 {
		panic("usage: yokey <mode>")
	}

	mode := os.Args[1]
	if mode == "gen" {
		key := generateMasterKeyBytes()
		fmt.Println(hex.EncodeToString(key))
		return
	}

	if mode == "sshsig-public" {
		master := readMasterKey()
		signer := deriveSSHSigSigner(master)
		fmt.Print(string(ssh.MarshalAuthorizedKey(signer.PublicKey())))
		return
	}

	if mode == "sshsig-sign" {
		if len(os.Args) != 4 {
			panic("usage: yokey sshsig-sign <namespace> <message>")
		}

		namespace := os.Args[2]
		message := []byte(os.Args[3])
		master := readMasterKey()
		signature := signSSHSig(master, namespace, message)
		fmt.Print(formatSignedMessage(string(message), signature))
		return
	}

	if mode == "sshsig-verify" {
		if len(os.Args) != 5 {
			panic("usage: yokey sshsig-verify <namespace> <message> <signature>")
		}

		namespace := os.Args[2]
		message := []byte(os.Args[3])
		signatureArg := strings.TrimSpace(os.Args[4])
		master := readMasterKey()

		signature, err := base64.StdEncoding.DecodeString(signatureArg)
		if err != nil {
			fmt.Println("invalid")
			os.Exit(1)
		}

		if err := verifySSHSig(master, namespace, message, signature); err != nil {
			fmt.Println("invalid")
			os.Exit(1)
		}

		fmt.Println("ok")
		return
	}

	master := readMasterKey()

	if mode == "passwd" {
		if len(os.Args) > 2 {
			fmt.Println(derivePassword(master, os.Args[2]))
			return
		} else {
			panic("must specify seed for password")
		}
	}

	var pub string
	var priv string

	if mode == "ed25519" {
		var privBytes []byte
		if len(os.Args) > 3 {
			pub, privBytes = deriveEd25519(master, os.Args[3])
		} else {
			pub, privBytes = deriveEd25519(master, "")
		}
		priv = string(privBytes)
	}

	if mode == "wg" {
		if len(os.Args) > 3 {
			pub, priv = deriveWireGuard(master, os.Args[3])
		} else {
			pub, priv = deriveWireGuard(master, "")
		}
	}

	if len(os.Args) > 2 {
		switch os.Args[2] {
		case "public":
			fmt.Print(pub)
			return
		case "private":
			fmt.Print(priv)
			return
		}
	} else {
		panic("must specify mode for key: private or public")
	}
}
