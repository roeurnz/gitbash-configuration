# 🧩 1️⃣ Install Git

## 🪟 Windows (includes Git Bash)

1. Download Git for Windows
2. Install with default settings
3. Ensure enabled:

   * Git Bash
   * OpenSSH
   * Git from command line

Verify:

```bash
git --version
```

---

## 🍎 macOS

Using Homebrew:

```bash
brew install git
```

Or:

```bash
xcode-select --install
```

Verify:

```bash
git --version
```

---

## 🐧 Ubuntu / Debian

```bash
sudo apt update
sudo apt install git openssh-client
```

Verify:

```bash
git --version
```

---

# 🧩 2️⃣ Install Git Desktop GUI

### For repositories on GitHub

Install GitHub Desktop:

* Sign in
* It integrates automatically with Git

### For GitLab or private servers

You may use:

* GitHub Desktop as generic client
* VS Code Git tools
* Sourcetree

---

# 🧩 3️⃣ Create SSH key folders

```bash
mkdir -p ~/.ssh/gitssh
mkdir -p ~/.ssh/serverssh
```

---

# 🧩 4️⃣ Generate SSH keys

## 🔐 Git hosting key

```bash
ssh-keygen -t ed25519 -C "git-access" -f ~/.ssh/gitssh/roeurnz
```

## 🖥 Server access key

```bash
ssh-keygen -t ed25519 -C "server-access" -f ~/.ssh/serverssh/roeurnz
```

Result:

```
~/.ssh/gitssh/roeurnz
~/.ssh/gitssh/roeurnz.pub

~/.ssh/serverssh/roeurnz
~/.ssh/serverssh/roeurnz.pub
```

---

# 🧩 5️⃣ Secure permissions

## macOS / Linux

```bash
chmod 700 ~/.ssh
chmod 700 ~/.ssh/gitssh
chmod 700 ~/.ssh/serverssh

chmod 600 ~/.ssh/gitssh/roeurnz
chmod 644 ~/.ssh/gitssh/roeurnz.pub

chmod 600 ~/.ssh/serverssh/roeurnz
chmod 644 ~/.ssh/serverssh/roeurnz.pub
```

## Windows (Git Bash)

```bash
chmod 600 ~/.ssh/gitssh/roeurnz
chmod 600 ~/.ssh/serverssh/roeurnz
```

---

# 🧩 6️⃣ Configure SSH

Edit:

```bash
~/.ssh/config
```

```ssh
Host *
    AddKeysToAgent yes
    IdentitiesOnly yes

Host github-roeurnz
    HostName github.com
    User git
    IdentityFile ~/.ssh/gitssh/roeurnz

Host gitlab-roeurnz
    HostName gitlab.com
    User git
    IdentityFile ~/.ssh/gitssh/roeurnz

Host myserver
    HostName MY_SERVER_IP_OR_DOMAIN
    User MY_SERVER_USERNAME
    Port 22
    IdentityFile ~/.ssh/serverssh/roeurnz

Host staging
    HostName MY_STAGING_SERVER
    User MY_SERVER_USERNAME
    Port 22
    IdentityFile ~/.ssh/serverssh/roeurnz
```

---

# 🧩 7️⃣ Start SSH agent and load keys

## macOS / Ubuntu

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/gitssh/roeurnz
ssh-add ~/.ssh/serverssh/roeurnz
```

## Windows (PowerShell)

```powershell
Start-Service ssh-agent
ssh-add $env:USERPROFILE\.ssh\gitssh\roeurnz
ssh-add $env:USERPROFILE\.ssh\serverssh\roeurnz
```

---

# 🧩 8️⃣ Copy public key to clipboard (NEW — paste directly into SSH key fields)

Use when adding keys to:

* GitHub → Settings → SSH Keys
* GitLab → Preferences → SSH Keys
* Linux servers (`authorized_keys`)

## 🪟 Windows (Git Bash)

```bash
clip < ~/.ssh/gitssh/roeurnz.pub
clip < ~/.ssh/serverssh/roeurnz.pub
```

## 🪟 Windows (PowerShell)

```powershell
Get-Content $env:USERPROFILE\.ssh\gitssh\roeurnz.pub | Set-Clipboard
Get-Content $env:USERPROFILE\.ssh\serverssh\roeurnz.pub | Set-Clipboard
```

## 🍎 macOS

```bash
pbcopy < ~/.ssh/gitssh/roeurnz.pub
pbcopy < ~/.ssh/serverssh/roeurnz.pub
```

## 🐧 Ubuntu / Linux

```bash
sudo apt install xclip
xclip -selection clipboard < ~/.ssh/gitssh/roeurnz.pub
xclip -selection clipboard < ~/.ssh/serverssh/roeurnz.pub
```

Paste directly — no extra spaces or line breaks.

---

# 🧩 9️⃣ Register public keys

## Git hosting accounts

Paste the copied key into your account SSH keys page.

## Linux servers

Append key to:

```
~/.ssh/authorized_keys
```

Or:

```bash
ssh-copy-id -i ~/.ssh/serverssh/roeurnz.pub user@server
```

---

# 🧩 🔟 Configure Git identity

```bash
git config --global user.name "ROEURNZ"
git config --global user.email "roeurnz@email.com"
```

Verify:

```bash
git config --list
```

---

# 🧩 1️⃣1️⃣ Usage

Clone repo:

```bash
git clone git@github-roeurnz:username/repository.git
git clone git@gitlab-roeurnz:username/repository.git
```

Connect to servers:

```bash
ssh myserver
ssh staging
```

---

# 🧩 1️⃣2️⃣ Test connections

```bash
ssh -T git@github-roeurnz
ssh -T git@gitlab-roeurnz
ssh myserver
```

---

# 🧩 1️⃣3️⃣ Optional improvements

Auto-load keys on login:

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/gitssh/roeurnz
ssh-add ~/.ssh/serverssh/roeurnz
```

Repo-specific identity:

```bash
git config user.name "Work Name"
git config user.email "work@email.com"
```

---

# ✅ Final architecture

```
~/.ssh/
 ├── gitssh/
 │   ├── roeurnz
 │   └── roeurnz.pub
 │
 ├── serverssh/
 │   ├── roeurnz
 │   └── roeurnz.pub
 │
 └── config
```

* separate Git + server identities
* multi-account ready
* multi-server ready
* secure permissions
* works on all OS
* CLI + GUI compatible
* clipboard-ready workflow
