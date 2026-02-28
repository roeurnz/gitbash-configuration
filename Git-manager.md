
# 📝 GitHub Manager for Multiple Accounts — Documentation (General) FYI

## Table of Contents

- [📝 GitHub Manager for Multiple Accounts — Documentation (General)](#-github-manager-for-multiple-accounts--documentation-general)
  - [Table of Contents](#table-of-contents)
  - [1️⃣ Purpose](#1️⃣-purpose)
  - [2️⃣ Prerequisites](#2️⃣-prerequisites)
  - [3️⃣ File Setup](#3️⃣-file-setup)
    - [A. SSH Config](#a-ssh-config)
    - [B. GitHub Manager Script](#b-github-manager-script)
    - [C. Bash Alias](#c-bash-alias)
  - [4️⃣ Using the Manager](#4️⃣-using-the-manager)
    - [List available accounts](#list-available-accounts)
    - [Switch account](#switch-account)
    - [Check status](#check-status)
  - [5️⃣ Cloning Repositories](#5️⃣-cloning-repositories)
  - [6️⃣ Handling Existing Repositories](#6️⃣-handling-existing-repositories)
  - [7️⃣ Common Git Errors \& Fixes](#7️⃣-common-git-errors--fixes)
  - [8️⃣ Tips \& Best Practices](#8️⃣-tips--best-practices)

---

## 1️⃣ Purpose

This setup allows you to:

* Manage **multiple GitHub accounts** on a single machine
* Automatically use the correct **SSH key** for each account
* Switch Git identity (name & email) per project
* Avoid permission conflicts when working with personal and work repositories

---

## 2️⃣ Prerequisites

* **Git** installed (Git Bash on Windows recommended)
* **SSH keys** generated for each GitHub account
* Basic knowledge of Git commands (`clone`, `push`, `pull`)

---

## 3️⃣ File Setup

### A. SSH Config

File: `~/.ssh/config`

```ssh
# Work GitHub account
Host github-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/work/id_ed25519
    IdentitiesOnly yes

# Personal GitHub account
Host github-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/personal/id_ed25519
    IdentitiesOnly yes
```

> ✅ This allows you to refer to each account via **host aliases** (`github-work`, `github-personal`) instead of `github.com`.

---

### B. GitHub Manager Script

File: `~/github-manager.sh`

```bash
#!/usr/bin/env bash

SSH_DIR="$HOME/.ssh"

declare -A ACCOUNTS
ACCOUNTS=(
  ["work"]="github-work|work-username|Full Name|work@example.com|$SSH_DIR/work/id_ed25519"
  ["personal"]="github-personal|personal-username|Full Name|personal@example.com|$SSH_DIR/personal/id_ed25519"
)

function list_accounts() {
  echo "Available GitHub accounts:"
  for key in "${!ACCOUNTS[@]}"; do
    IFS='|' read -r HOST USER NAME EMAIL KEY <<< "${ACCOUNTS[$key]}"
    echo " - $key ($USER | $EMAIL)"
  done
}

function use_account() {
  local key="$1"

  if [[ -z "${ACCOUNTS[$key]}" ]]; then
    echo "❌ Account '$key' not found"
    list_accounts
    exit 1
  fi

  IFS='|' read -r HOST USER NAME EMAIL KEY <<< "${ACCOUNTS[$key]}"

  echo "🔄 Switching to GitHub account: $key"

  eval "$(ssh-agent -s)" > /dev/null
  ssh-add -D > /dev/null 2>&1
  ssh-add "$KEY"

  git config --local user.name "$NAME"
  git config --local user.email "$EMAIL"

  echo "✅ GitHub user : $USER"
  echo "✅ Git name   : $NAME"
  echo "✅ Git email  : $EMAIL"
  echo "✅ SSH key    : $KEY"
  echo
  echo "👉 Use this host when cloning:"
  echo "   git clone git@$HOST:$USER/REPO.git"
}

function status() {
  echo "🔐 SSH keys loaded:"
  ssh-add -l || echo "No ssh-agent running"

  echo
  echo "📦 Repo git identity:"
  git config user.name
  git config user.email
}

case "$1" in
  list)
    list_accounts
    ;;
  use)
    use_account "$2"
    ;;
  status)
    status
    ;;
  *)
    echo "GitHub Manager"
    echo
    echo "Usage:"
    echo "  ghm list"
    echo "  ghm use <work|personal>"
    echo "  ghm status"
    ;;
esac
```

---

### C. Bash Alias

File: `~/.bashrc` or `~/.bash_profile` (Windows Git Bash)

```bash
alias ghm="~/github-manager.sh"
```

* Reload Bash:

```bash
source ~/.bashrc
```

* Use `ghm` as a shortcut:

```bash
ghm list       # List accounts
ghm use work   # Switch to work account
ghm use personal # Switch to personal account
ghm status     # Show current SSH and Git identity
```

---

## 4️⃣ Using the Manager

### List available accounts

```bash
ghm list
```

Output:

```
Available GitHub accounts:
 - personal (personal-username | personal@example.com)
 - work (work-username | work@example.com)
```

### Switch account

```bash
ghm use work
```

* Loads the SSH key
* Sets Git user.name and user.email for current repo
* Shows the host alias to use for cloning

### Check status

```bash
ghm status
```

Shows:

* Loaded SSH keys
* Current Git identity

---

## 5️⃣ Cloning Repositories

* Always use **host alias** from SSH config:

```bash
git clone git@github-work:ORG/REPO.git
git clone git@github-personal:USERNAME/REPO.git
```

> ❌ Avoid `git@github.com:...` directly, as it may pick the wrong key.

---

## 6️⃣ Handling Existing Repositories

If a repo is cloned using `github.com`:

1. Update remote to use host alias:

```bash
git remote set-url origin git@github-work:ORG/REPO.git
```

or

```bash
git remote set-url origin git@github-personal:USERNAME/REPO.git
```

2. Pull, push, and commit normally.

---

## 7️⃣ Common Git Errors & Fixes

| Error                                        | Cause                      | Fix                                                  |
| -------------------------------------------- | -------------------------- | ---------------------------------------------------- |
| `Permission denied (publickey)`              | Wrong SSH key / host       | Use `ghm use <account>` and check remote host        |
| `non-fast-forward`                           | Local branch behind remote | `git pull --rebase origin main`                      |
| `ssh: Could not resolve hostname github.com` | DNS / network              | Check `ping github.com`, flush DNS, restart Git Bash |

---

## 8️⃣ Tips & Best Practices

* Use **rebase** by default:

```bash
git config --global pull.rebase true
```

* Always **check remote** after switching accounts:

```bash
git remote -v
```

* Keep **SSH keys secured** (`chmod 600 ~/.ssh/*`)

* Test your connection:

```bash
ssh -T git@github-work
ssh -T git@github-personal
```

* Clone new repos using **host alias** to avoid conflicts.

* Optional: Add a `ghm work` script to verify:

  * Loaded keys
  * Git identity
  * Remote host matches the account



