#!/bin/bash

echo "🛠️ Memulai proses setup Aztec Sequencer..."

# Update sistem dan install dependensi dasar
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl wget build-essential jq tmux unzip

# Pasang Node.js (versi LTS via nvm)
echo "📦 Memasang Node.js..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
source "$NVM_DIR/nvm.sh"
nvm install --lts
nvm use --lts

# Pasang Yarn via corepack
corepack enable
corepack prepare yarn@stable --activate

# Clone repo Aztec dan masuk ke direktori
echo "📥 Mengunduh repositori Aztec..."
git clone https://github.com/AztecProtocol/aztec-packages.git
cd aztec-packages

# Checkout branch yang sesuai (ubah jika perlu)
git checkout master

# Instal dependensi dan build
echo "🔧 Instal dependensi dan build..."
yarn install
yarn build

# Jalankan sequencer
echo "🚀 Menjalankan Aztec sequencer node..."
yarn start:sequencer
