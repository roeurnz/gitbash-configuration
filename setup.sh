#!/usr/bin/env bash

set -e

echo "🚀 Starting SSH + Git environment setup..."

############################################
# CONFIGURATION (EDIT IF NEEDED)
############################################

GIT_KEY="$HOME/.ssh/gitssh/roeurnz"
SERVER_KEY="$HOME/.ssh/serverssh/roeurnz"

GITHUB_HOST="github-roeurnz"
GITLAB_HOST="gitlab-roeurnz"

SERVER_HOST_ALIAS="myserver"
SERVER_HOSTNAME="MY_SERVER_IP_OR_DOMAIN"
SERVER_USER="MY_SERVER_USERNAME"

STAGING_ALIAS="staging"
STAGING_HOSTNAME="MY_STAGING_SERVER"
STAGING_USER="MY_SERVER_USERNAME"

############################################
# CREATE FOLDERS
############################################

echo "📁 Creating SSH folders..."
mkdir -p "$HOME/.ssh/gitssh"
mkdir -p "$HOME/.ssh/serverssh"

############################################
# GENERATE KEYS IF NOT EXIST
############################################

if [ ! -f "$GIT_KEY" ]; then
    echo "🔐 Generating Git SSH key..."
    ssh-keygen -t ed25519 -C "git-access" -f "$GIT_KEY" -N ""
else
    echo "✔ Git SSH key already exists"
fi

if [ ! -f "$SERVER_KEY" ]; then
    echo "🖥 Generating Server SSH key..."
    ssh-keygen -t ed25519 -C "server-access" -f "$SERVER_KEY" -N ""
else
    echo "✔ Server SSH key already exists"
fi

############################################
# SET PERMISSIONS
############################################

echo "🔒 Setting permissions..."
chmod 700 "$HOME/.ssh"
chmod 700 "$HOME/.ssh/gitssh"
chmod 700 "$HOME/.ssh/serverssh"

chmod 600 "$GIT_KEY"
chmod 644 "$GIT_KEY.pub"

chmod 600 "$SERVER_KEY"
chmod 644 "$SERVER_KEY.pub"

############################################
# WRITE SSH CONFIG
############################################

CONFIG_FILE="$HOME/.ssh/config"

echo "🧩 Writing SSH config..."

cat > "$CONFIG_FILE" <<EOF
Host *
    AddKeysToAgent yes
    IdentitiesOnly yes

Host $GITHUB_HOST
    HostName github.com
    User git
    IdentityFile $GIT_KEY

Host $GITLAB_HOST
    HostName gitlab.com
    User git
    IdentityFile $GIT_KEY

Host $SERVER_HOST_ALIAS
    HostName $SERVER_HOSTNAME
    User $SERVER_USER
    Port 22
    IdentityFile $SERVER_KEY

Host $STAGING_ALIAS
    HostName $STAGING_HOSTNAME
    User $STAGING_USER
    Port 22
    IdentityFile $SERVER_KEY
EOF

chmod 600 "$CONFIG_FILE"

############################################
# START SSH AGENT
############################################

echo "🔑 Loading SSH agent..."

if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    eval "$(ssh-agent -s)"
fi

ssh-add "$GIT_KEY" || true
ssh-add "$SERVER_KEY" || true

############################################
# SUCCESS OUTPUT
############################################

echo ""
echo "✅ Setup complete!"
echo ""
echo "📋 Copy keys to clipboard manually:"
echo ""

echo "Git key:"
echo "cat $GIT_KEY.pub"
echo ""

echo "Server key:"
echo "cat $SERVER_KEY.pub"
echo ""

echo "🔌 Test connections:"
echo "ssh -T git@$GITHUB_HOST"
echo "ssh $SERVER_HOST_ALIAS"
echo ""

echo "🎉 All done."
