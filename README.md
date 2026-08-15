# Vault

Personal secret backup, dipakai `~/.dotfiles/setup.sh` saat setup laptop baru.

> **WARNING** — remote `reimiii/vault` ini repo **public**. Hanya commit secret yang
> sudah dienkripsi ansible-vault. Kalau private key pernah ter-commit plaintext,
> langsung **rotasi** — hapus/history rewrite tidak cukup.

## Isi

| Path | Isi | Di repo |
|---|---|---|
| `.ssh/id_ed25519` | SSH private key (Ed25519) | ansible-vault encrypted |
| `.ssh/id_ed25519.pub` | SSH public key | plaintext (publik) |
| `.ssh/known_hosts` | sidik jari host | plaintext (publik) |
| `gpg/key.asc` | export GPG secret key | ansible-vault encrypted |
| `.gitconfig` | identitas git + signing key | plaintext |

Semua file ansible-vault pakai satu vault password (diminta `ansible-vault`).
**Simpan password-nya di password manager** — kalau lupa, backup tidak bisa dibuka.

## Perintah

```bash
./scripts/decrypt.sh        # decrypt secret untuk dipakai/cek lokal
./scripts/encrypt.sh        # encrypt ulang setelah edit
./scripts/guard.sh          # verifikasi tidak ada secret plaintext
./scripts/backup.sh         # encrypt + commit + push
./scripts/install-hooks.sh  # pasang pre-commit guard (jalankan sekali per clone)
```

## Setup laptop baru

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/reimiii/.dotfiles/main/install.sh)
```

Alur: clone vault (HTTPS) → minta vault password → decrypt ke temp dir → install
`~/.ssh`, import GPG, load `ssh-agent`, pasang hook, switch remote ke SSH.

## Backup / restore GPG & SSH

```bash
gpg --list-secret-keys --keyid-format LONG
gpg --export-secret-keys $ID > gpg/key.asc   # lalu ./scripts/encrypt.sh
gpg --import gpg/key.asc

cp ~/.ssh/id_ed25519 vault/.ssh/id_ed25519   # lalu ./scripts/encrypt.sh
ssh-add ~/.ssh/id_ed25519
```

Ingat `GPG_TTY=$(tty)` untuk prompt passphrase.
