#!/bin/bash

# Set filenames
KEY_FILE="key.age"
PUBLIC_KEY_FILE="public.key"
INPUT_FILE="nsp-sensitive-vars.yml"
ENCRYPTED_FILE="nsp-sensitive-vars.yml.age"

# Function to generate an age key
generate_key() {
    echo "Generating age key..."
    age-keygen > "$KEY_FILE"

    # Extract public key from generated key file
    PUBLIC_KEY=$(grep -oE "age1[a-zA-Z0-9]+" "$KEY_FILE")

    if [ -z "$PUBLIC_KEY" ]; then
        echo "Error: Failed to extract public key from generated key file."
        exit 1
    fi

    echo "$PUBLIC_KEY" > "$PUBLIC_KEY_FILE"
    echo "Key file created: $KEY_FILE"
    echo "Public key saved to: $PUBLIC_KEY_FILE"
}

# Function to encrypt file
encrypt_file() {
    if [ ! -f "$PUBLIC_KEY_FILE" ]; then
        echo "Error: Public key file ($PUBLIC_KEY_FILE) not found! Generate it first."
        exit 1
    fi

    PUBLIC_KEY=$(cat "$PUBLIC_KEY_FILE")

    echo "Encrypting file: $INPUT_FILE..."
    age -r "$PUBLIC_KEY" -o "$ENCRYPTED_FILE" "$INPUT_FILE"
    echo "Encryption complete: $ENCRYPTED_FILE"
}

# Function to decrypt file
decrypt_file() {
    if [ ! -f "$KEY_FILE" ]; then
        echo "Error: Key file ($KEY_FILE) not found!"
        exit 1
    fi

    if [ ! -f "$ENCRYPTED_FILE" ]; then
        echo "Error: Encrypted file ($ENCRYPTED_FILE) not found!"
        exit 1
    fi

    echo "Decrypting file: $ENCRYPTED_FILE..."
    age -d -i "$KEY_FILE" -o "$INPUT_FILE" "$ENCRYPTED_FILE"
    echo "Decryption complete: $INPUT_FILE"
}

# Function to encrypt with SSH key
encrypt_with_ssh() {
    SSH_PUBLIC_KEY="$HOME/.ssh/id_ed25519.pub"

    if [ ! -f "$SSH_PUBLIC_KEY" ]; then
        echo "Error: SSH public key ($SSH_PUBLIC_KEY) not found!"
        exit 1
    fi

    echo "Encrypting file using SSH public key..."
    age -R "$SSH_PUBLIC_KEY" -o "$ENCRYPTED_FILE" "$INPUT_FILE"
    echo "Encryption complete: $ENCRYPTED_FILE"
}

# Function to decrypt with SSH key
decrypt_with_ssh() {
    SSH_PRIVATE_KEY="$HOME/.ssh/id_ed25519"

    if [ ! -f "$SSH_PRIVATE_KEY" ]; then
        echo "Error: SSH private key ($SSH_PRIVATE_KEY) not found!"
        exit 1
    fi

    echo "Decrypting file using SSH private key..."
    age -d -i "$SSH_PRIVATE_KEY" -o "$INPUT_FILE" "$ENCRYPTED_FILE"
    echo "Decryption complete: $INPUT_FILE"
}

# Help message
show_help() {
    echo "Usage: $0 [option]"
    echo "Options:"
    echo "  generate-key     Generate a new age key"
    echo "  encrypt          Encrypt nsp-sensitive-vars.yml"
    echo "  decrypt          Decrypt nsp-sensitive-vars.yml.age"
    echo "  encrypt-ssh      Encrypt using SSH public key"
    echo "  decrypt-ssh      Decrypt using SSH private key"
    echo "  help             Show this help message"
}

# Main script logic
case "$1" in
    generate-key) generate_key ;;
    encrypt) encrypt_file ;;
    decrypt) decrypt_file ;;
    encrypt-ssh) encrypt_with_ssh ;;
    decrypt-ssh) decrypt_with_ssh ;;
    help|*) show_help ;;
esac
