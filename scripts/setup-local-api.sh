#!/bin/bash

# =====================================================
# Telegram Local Bot API Server Setup Script
# For Ubuntu/Debian VPS
# =====================================================
# This script installs and configures the Telegram Local Bot API Server
# which allows 2GB file uploads/downloads (vs 20MB/50MB limits)
# =====================================================

set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║   Telegram Local Bot API Server - Setup Script             ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Please run as root (sudo ./setup-local-api.sh)"
    exit 1
fi

# Check arguments
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: sudo ./setup-local-api.sh <21562829> <27d43298df18cf3ada9e56b174b0e305>"
    echo ""
    echo "Get API_ID and API_HASH from https://my.telegram.org"
    echo ""
    echo "Example:"
    echo "  sudo ./setup-local-api.sh 12345678 abcdef1234567890"
    exit 1
fi

API_ID=$1
API_HASH=$2

echo "📦 Installing dependencies..."
apt-get update
apt-get install -y make git zlib1g-dev libssl-dev gperf cmake g++ build-essential

echo ""
echo "📥 Cloning Telegram Bot API repository..."
cd /opt
if [ -d "telegram-bot-api" ]; then
    echo "   Repository already exists, pulling latest..."
    cd telegram-bot-api
    git pull
else
    git clone --recursive https://github.com/tdlib/telegram-bot-api.git
    cd telegram-bot-api
fi

echo ""
echo "🔨 Building Telegram Bot API Server..."
echo "   This may take 10-30 minutes depending on your VPS specs..."
rm -rf build
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr/local ..
cmake --build . --target install -j $(nproc)

echo ""
echo "📝 Creating systemd service..."
cat > /etc/systemd/system/telegram-bot-api.service << EOF
[Unit]
Description=Telegram Bot API Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/telegram-bot-api --api-id=${API_ID} --api-hash=${API_HASH} --local --http-port=8081
Restart=always
RestartSec=5
User=root
WorkingDirectory=/opt/telegram-bot-api

[Install]
WantedBy=multi-user.target
EOF

echo ""
echo "🚀 Starting Telegram Bot API Server..."
systemctl daemon-reload
systemctl enable telegram-bot-api
systemctl start telegram-bot-api

# Wait a moment for service to start
sleep 3

# Check if running
if systemctl is-active --quiet telegram-bot-api; then
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║   ✅ Installation Complete!                                ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Local Bot API Server is running on: http://localhost:8081"
    echo ""
    echo "📋 Next Steps:"
    echo "   1. Add to your .env file:"
    echo "      LOCAL_API_URL=http://localhost:8081"
    echo ""
    echo "   2. Restart your bot:"
    echo "      pm2 restart web2apk"
    echo ""
    echo "📊 Useful Commands:"
    echo "   Check status:  systemctl status telegram-bot-api"
    echo "   View logs:     journalctl -u telegram-bot-api -f"
    echo "   Restart:       systemctl restart telegram-bot-api"
    echo ""
else
    echo "❌ Failed to start Telegram Bot API Server"
    echo "   Check logs: journalctl -u telegram-bot-api -e"
    exit 1
fi
