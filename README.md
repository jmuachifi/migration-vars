# Migration variables using age tool
Migration AzDo vars to VCS context

> Age is a simple, modern and secure file encryption tool, format, and Go library. It features small explicit keys, no config options, and UNIX-style composability.


# **Age Encryption Utility**

A simple script to encrypt and decrypt sensitive files using the **age** tool. This ensures secure handling of secrets, especially in CI/CD pipelines.

## **Prerequisites**
Before using this script, ensure you have the **age** tool installed.  
If not, install it via:

### **MacOS (Homebrew)**
```bash
brew install age
```

### **Linux**
```bash
sudo apt install age  # Debian/Ubuntu
sudo dnf install age  # Fedora
```

### **Windows**
Download the latest release from: [Filippo.io/age](https://filippo.io/age/)

---

## **Usage Instructions**

### **1️⃣ Generate Encryption Key Pair**
This command generates an **age** key file (`key.age`) and extracts the **public key** (`public.key`).

```bash
./encrypt-decrypt.sh generate-key
```
🔹 **Outputs:**
- `key.age` → **Private key** (DO NOT SHARE!)
- `public.key` → **Public key** (Used for encryption)

---

### **2️⃣ Encrypt a Sensitive File**
Encrypts `nsp-sensitive-vars.yml` into `nsp-sensitive-vars.yml.age`.

```bash
./encrypt-decrypt.sh encrypt
```
🔹 **Outputs:**  
- `nsp-sensitive-vars.yml.age` (Encrypted file)

---

### **3️⃣ Decrypt the Encrypted File**
Decrypts `nsp-sensitive-vars.yml.age` back to its original form.

```bash
./encrypt-decrypt.sh decrypt
```
🔹 **Restores:**  
- `nsp-sensitive-vars.yml` (Original file)

---

### **4️⃣ Encrypt Using an SSH Key**
You can also encrypt the file using an **SSH public key** (`~/.ssh/id_ed25519.pub`).

```bash
./encrypt-decrypt.sh encrypt-ssh
```
🔹 **Outputs:**  
- `nsp-sensitive-vars.yml.age` (Encrypted file using SSH)

---

### **5️⃣ Decrypt Using an SSH Key**
To decrypt using an SSH private key (`~/.ssh/id_ed25519`):

```bash
./encrypt-decrypt.sh decrypt-ssh
```
🔹 **Restores:**  
- `nsp-sensitive-vars.yml`


---

## **Security Considerations**
✅ **DO NOT COMMIT `key.age`** – This file contains your **private key**.  
✅ **Store keys securely** – Use **GitHub Secrets**, **Vault**, or a secure storage system.  
✅ **Use the public key (`public.key`) for encryption** – The private key is only needed for decryption.

---

### **📌 Troubleshooting**
#### ❓ *"Error: Key file (key.age) not found!"*
- Ensure you have run `./encrypt-decrypt.sh generate-key` before encrypting or decrypting.

#### ❓ *"Error: Encrypted file not found!"*
- Run `./encrypt-decrypt.sh encrypt` to generate the encrypted file first.

---

## **Conclusion**
This script provides a simple yet powerful way to securely encrypt and decrypt files using **age** or **SSH keys**. 🎯


