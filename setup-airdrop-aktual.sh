#!/bin/bash

echo "========================================="
echo "        🔵 Airdrop Aktual - Aztec Node Setup"
echo "     📢 t.me/airdropfaktual"
echo "========================================="

# Periksa OS
if [ "$(lsb_release -is)" != "Ubuntu" ]; then
  echo "Script ini hanya untuk Ubuntu!"
  exit 1
fi

# Update system
echo "[1/7] Updating system..."
sudo apt-get update && sudo apt-get upgrade -y

# Install dependencies
echo "[2/7] Installing dependencies..."
sudo apt install -y curl wget git jq nano build-essential lz4 pkg-config libssl-dev libgbm1 libleveldb-dev unzip

# Install Docker
echo "[3/7] Installing Docker..."
curl -fsSL https://get.docker.com | sudo bash
sudo usermod -aG docker $USER

# Install Aztec CLI
echo "[4/7] Installing Aztec CLI..."
bash -i <(curl -s https://install.aztec.network)

# Dapatkan input pengguna
echo "[5/7] Masukkan data konfigurasi Anda:"

read -p "RPC Sepolia (Execution Layer): " EXEC_RPC
read -p "RPC Sepolia (Consensus Layer): " CONS_RPC
read -p "Private Key (tanpa 0x): " ETH_KEY
read -p "Public Address: " ETH_ADDR
read -p "Public IP VPS Anda: " VPS_IP

echo ""
echo "Konfirmasi Data:"
echo "RPC Execution : $EXEC_RPC"
echo "RPC Consensus : $CONS_RPC"
echo "ETH Address   : $ETH_ADDR"
echo "Public IP     : $VPS_IP"
read -p "Lanjutkan instalasi? (y/n): " CONFIRM

if [[ "$CONFIRM" != "y" ]]; then
  echo "❌ Batal."
  exit 1
fi

# Jalankan node Aztec
echo "[6/7] Menjalankan node Aztec..."
aztec start --node --archiver --sequencer \
  --network alpha-testnet \
  --l1-rpc-urls $EXEC_RPC \
  --l1-consensus-host-urls $CONS_RPC \
  --sequencer.validatorPrivateKey 0x$ETH_KEY \
  --sequencer.coinbase $ETH_ADDR \
  --p2p.p2pIp $VPS_IP \
  --p2p.maxTxPoolSize 1000000000

# Tambah cronjob auto update
echo "[7/7] Menambahkan cronjob auto-update..."
(crontab -l ; echo "0 4 * * * aztec-up alpha-testnet >> ~/aztec-update.log 2>&1") | crontab -

# Buat monitoring script
cat <<EOF > ~/monitor.sh
#!/bin/bash
echo "🔍 Monitoring Aztec Node"
BLOCK=\$(curl -s -X POST -H 'Content-Type: application/json' \\
  -d '{"jsonrpc":"2.0","method":"node_getL2Tips","params":[],"id":67}' \\
  http://localhost:8080 | jq -r '.result.proven.number')

echo "✅ Latest Proven Block: \$BLOCK"
echo "📦 Docker Container Status:"
docker ps
EOF

chmod +x ~/monitor.sh

echo ""
echo "✅ Instalasi selesai!"
echo "➤ Untuk monitoring: ~/monitor.sh"
echo "➤ Join komunitas: https://t.me/airdropfaktual"
