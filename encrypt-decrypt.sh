#!/bin/bash

# Default filenames (Can be overridden by environment variables or command-line arguments)
KEY_FILE="${KEY_FILE:-key.age}"
PUBLIC_KEY_FILE="${PUBLIC_KEY_FILE:-public.key}"
INPUT_FILE="${1:-nsp-sensitive-vars.yml}"
ENCRYPTED_FILE="${2:-${INPUT_FILE}.age}"

# Check if age is installed
check_dependencies() {
    if ! command -v age &>/dev/null; then
        echo "Error: 'age' is not installed. Install it using: sudo apt install age"
        exit 1
    fi
}

# Function to generate an age key
generate_key() {
    check_dependencies
    echo "Generating age key..."
    age-keygen > "$KEY_FILE"

    # Extract public key from generated key file
    PUBLIC_KEY=$(grep -oE "age1[a-zA-Z0-9]+" "$KEY_FILE")

    if [ -z "$PUBLIC_KEY" ]; then
        echo "Error: Failed to extract public key from generated key file."
        exit 1
    fi

    echo "$PUBLIC_KEY" > "$PUBLIC_KEY_FILE"
    echo "✅ Key file created: $KEY_FILE"
    echo "✅ Public key saved to: $PUBLIC_KEY_FILE"
}

# Function to encrypt file
encrypt_file() {
    check_dependencies

    if [ ! -f "$PUBLIC_KEY_FILE" ]; then
        echo "Error: Public key file ($PUBLIC_KEY_FILE) not found! Generate it first."
        exit 1
    fi

    PUBLIC_KEY=$(cat "$PUBLIC_KEY_FILE")

    if [ ! -f "$INPUT_FILE" ]; then
        echo "Error: Input file ($INPUT_FILE) not found!"
        exit 1
    fi

    echo "🔒 Encrypting file: $INPUT_FILE..."
    age -r "$PUBLIC_KEY" -o "$ENCRYPTED_FILE" "$INPUT_FILE"
    echo "✅ Encryption complete: $ENCRYPTED_FILE"
}

# Function to decrypt file
decrypt_file() {
    check_dependencies

    if [ ! -f "$KEY_FILE" ]; then
        echo "Error: Key file ($KEY_FILE) not found!"
        exit 1
    fi

    if [ ! -f "$ENCRYPTED_FILE" ]; then
        echo "Error: Encrypted file ($ENCRYPTED_FILE) not found!"
        exit 1
    fi

    echo "🔓 Decrypting file: $ENCRYPTED_FILE..."
    age -d -i "$KEY_FILE" -o "$INPUT_FILE" "$ENCRYPTED_FILE"
    echo "✅ Decryption complete: $INPUT_FILE"
}

# Function to encrypt with SSH key
encrypt_with_ssh() {
    check_dependencies
    SSH_PUBLIC_KEY="$HOME/.ssh/id_ed25519.pub"

    if [ ! -f "$SSH_PUBLIC_KEY" ]; then
        echo "Error: SSH public key ($SSH_PUBLIC_KEY) not found!"
        exit 1
    fi

    if [ ! -f "$INPUT_FILE" ]; then
        echo "Error: Input file ($INPUT_FILE) not found!"
        exit 1
    fi

    echo "🔒 Encrypting file using SSH public key..."
    age -R "$SSH_PUBLIC_KEY" -o "$ENCRYPTED_FILE" "$INPUT_FILE"
    echo "✅ Encryption complete: $ENCRYPTED_FILE"
}

# Function to decrypt with SSH key
decrypt_with_ssh() {
    check_dependencies
    SSH_PRIVATE_KEY="$HOME/.ssh/id_ed25519"

    if [ ! -f "$SSH_PRIVATE_KEY" ]; then
        echo "Error: SSH private key ($SSH_PRIVATE_KEY) not found!"
        exit 1
    fi

    if [ ! -f "$ENCRYPTED_FILE" ]; then
        echo "Error: Encrypted file ($ENCRYPTED_FILE) not found!"
        exit 1
    fi

    echo "🔓 Decrypting file using SSH private key..."
    age -d -i "$SSH_PRIVATE_KEY" -o "$INPUT_FILE" "$ENCRYPTED_FILE"
    echo "✅ Decryption complete: $INPUT_FILE"
}

# Help message
show_help() {
    echo "Usage: $0 [option] [input_file] [output_file]"
    echo "Options:"
    echo "  generate-key              Generate a new age key"
    echo "  encrypt [input] [output]  Encrypt file (default: nsp-sensitive-vars.yml)"
    echo "  decrypt [input] [output]  Decrypt file (default: nsp-sensitive-vars.yml.age)"
    echo "  encrypt-ssh [input] [output]  Encrypt using SSH public key"
    echo "  decrypt-ssh [input] [output]  Decrypt using SSH private key"
    echo "  help                      Show this help message"
}

# Main script logic
case "$1" in
    generate-key) generate_key ;;
    encrypt) encrypt_file "$2" "$3" ;;
    decrypt) decrypt_file "$2" "$3" ;;
    encrypt-ssh) encrypt_with_ssh "$2" "$3" ;;
    decrypt-ssh) decrypt_with_ssh "$2" "$3" ;;
    help|*) show_help ;;
esac
