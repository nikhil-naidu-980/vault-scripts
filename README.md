# vault-scripts

This repository contains two shell scripts for managing secrets in HashiCorp Vault: `vault-copy.sh` and `vault-delete.sh`. These scripts are designed to help with copying and deleting secrets recursively within Vault.

## `vault-copy.sh` - Recursively Copy Secrets in Vault

This script allows you to copy secrets from one path to another in HashiCorp Vault. It can handle both secrets and directories within Vault, copying all items recursively.

### Requirements
- `vault` CLI installed and configured
- `jq` installed to parse JSON output from Vault
- A valid Vault token with read and write permissions to the source and destination paths

### Usage

```bash
./vault-copy.sh <source-path> <destination-path>
```

- `<source-path>`: The source path in Vault from which secrets will be copied.
- `<destination-path>`: The destination path in Vault to which secrets will be copied.

### Example

```bash
./vault-copy.sh secret/data/dev secret/data/prod
```

This command will recursively copy all secrets from `secret/data/dev` to `secret/data/prod`.

### How it Works
- The script uses `vault kv list` to list all secrets and directories under the given source path.
- It then loops through each item, checking if it's a secret or a directory.
  - If it's a directory, it creates a corresponding empty directory at the destination path, and recursively processes its contents.
  - If it's a secret, it copies the secret data from the source to the destination using `vault kv get` and `vault kv put`.

---

## `vault-delete.sh` - Recursively Delete Secrets in Vault

This script allows you to delete secrets and directories recursively from a specified path in HashiCorp Vault.

### Requirements
- `vault` CLI installed and configured
- `jq` installed to parse JSON output from Vault
- A valid Vault token with delete permissions to the target path

### Usage

```bash
./vault-delete.sh <path>
```

- `<path>`: The path in Vault from which secrets and directories will be deleted.

### Example

```bash
./vault-delete.sh secret/data/dev
```

This command will recursively delete all secrets and directories under `secret/data/dev`.

### How it Works
- The script uses `vault kv list` to list all secrets and directories under the given path.
- It loops through each item, checking if it's a secret or a directory.
  - If it's a directory, it recursively processes the contents of the subdirectory.
  - If it's a secret, it deletes it using `vault kv delete`.

---

## Notes

- **Permissions**: Make sure the Vault token you're using has appropriate permissions for the operations you want to perform. For the `vault-copy.sh` script, the token should have read access to the source path and write access to the destination path. For `vault-delete.sh`, the token should have delete permissions for the target path.
  
- **jq**: If you don't have `jq` installed, you can install it by running:
  - **For Ubuntu/Debian**: `sudo apt-get install jq`
  - **For macOS**: `brew install jq`

---

