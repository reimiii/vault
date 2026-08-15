# Vault

**Encrypted-at-rest backup of personal secrets (SSH + GPG keys), kept in sync on
GitHub and consumed by [`~/.dotfiles/setup.sh`](https://github.com/reimiii/.dotfiles)
when setting up a new machine.**

## Intent

This repo is a single source of truth for the secrets you need on a fresh laptop:

- your **SSH private key** (Ed25519) — used for GitHub and general `ssh` auth
- your **GPG secret key** — used for signed git commits
- your **git identity** (`.gitconfig`) and SSH host fingerprints

Nothing secret is ever stored in plaintext here.

> **Security note** — the remote `reimiii/vault` is a **public** repo. This is safe
> *only because* every secret is encrypted with ansible-vault before committing.
> The consequence: if a private key is ever committed as plaintext, it must be
> **rotated** (regenerated) — deleting it or rewriting history is not enough.

## Contents

| Path | What it is | Stored as |
|---|---|---|
| `.ssh/id_ed25519` | SSH private key (Ed25519) | ansible-vault encrypted |
| `.ssh/id_ed25519.pub` | SSH public key | plaintext (public by design) |
| `.ssh/known_hosts` | SSH host fingerprints | plaintext (public by design) |
| `gpg/key.asc` | exported GPG secret key | ansible-vault encrypted |
| `.gitconfig` | git identity + signing key | plaintext |

All ansible-vault files share a single **vault password** (prompted by
`ansible-vault`). Store that password in a password manager — if it is lost,
the encrypted backups cannot be opened.

## Usage

```bash
./scripts/decrypt.sh        # decrypt secrets for local use/inspection
./scripts/encrypt.sh        # re-encrypt after editing secrets (runs guard check)
./scripts/guard.sh          # verify no secret is left in plaintext
./scripts/backup.sh         # ensure encrypted, then commit + push
./scripts/install-hooks.sh  # install pre-commit guard (run once per clone)
```

**Recommended safety flow:** run `./scripts/install-hooks.sh` once after every
clone. The pre-commit hook then refuses any commit that would push a plaintext
secret — the most common way a leak happens.

## Setting up a new laptop

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/reimiii/.dotfiles/main/install.sh)
```

That flow: clone vault over HTTPS → prompt for the vault password → decrypt the
secrets to a **temp directory** (the working tree always stays encrypted) → install
`~/.ssh` with `chmod 600` → import the GPG key → load `ssh-agent` → install the
vault pre-commit hook → switch remotes to SSH.

## Updating a key (SSH or GPG)

1. Copy the new key into the vault (below).
2. Run `./scripts/encrypt.sh` (enter the vault password).
3. Run `./scripts/backup.sh` to commit and push.

SSH:

```bash
cp ~/.ssh/id_ed25519 vault/.ssh/id_ed25519
cp ~/.ssh/id_ed25519.pub vault/.ssh/id_ed25519.pub
```

GPG:

```bash
gpg --list-secret-keys --keyid-format LONG
gpg --export-secret-keys <ID> > vault/gpg/key.asc   # <ID> = fingerprint after the slash
```

## Restoring on the current machine

```bash
gpg --import gpg/key.asc          # after decrypting
ssh-add ~/.ssh/id_ed25519
```

Note: set `GPG_TTY=$(tty)` (e.g. in `~/.bashrc`) so gpg can prompt for the
passphrase in a terminal.
