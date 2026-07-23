#!/data/data/com.termux/files/usr/bin/bash
#
# Termux DNS Rotator - Installer
#

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}[*] Termux DNS Rotator installer${NC}"

# Check we're in Termux
if [[ -z "${PREFIX:-}" ]]; then
  echo -e "${RED}[!] This script must be run inside Termux${NC}"
  exit 1
fi

# Install dependencies if missing
if ! command -v sv >/dev/null 2>&1; then
  echo -e "${YELLOW}[*] Installing termux-services...${NC}"
  pkg install termux-services -y
fi

# Install the binary
echo -e "${GREEN}[*] Installing dns-rotator to \$PREFIX/bin${NC}"
cp dns-rotator "$PREFIX/bin/dns-rotator"
chmod +x "$PREFIX/bin/dns-rotator"

# Config
mkdir -p "$HOME/.config/dns-rotator"
if [[ ! -f "$HOME/.config/dns-rotator/config" ]]; then
  cp dns-rotator.conf "$HOME/.config/dns-rotator/config"
  echo -e "${GREEN}[*] Default config written to ~/.config/dns-rotator/config${NC}"
else
  echo -e "${YELLOW}[*] Config already exists – leaving it untouched${NC}"
fi

# Create service
SERVICE_DIR="$PREFIX/var/service/dns-rotator"
echo -e "${GREEN}[*] Setting up termux-services daemon${NC}"
mkdir -p "$SERVICE_DIR/log"

cat > "$SERVICE_DIR/run" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
exec 2>&1
exec dns-rotator
EOF
chmod +x "$SERVICE_DIR/run"

cat > "$SERVICE_DIR/log/run" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
exec svlogd -tt ./main
EOF
chmod +x "$SERVICE_DIR/log/run"

# Enable + start
sv-enable dns-rotator 2>/dev/null || true
sv up dns-rotator

sleep 1
STATUS=$(sv status dns-rotator 2>/dev/null || echo "unknown")

echo
echo -e "${GREEN}[+] Installation complete${NC}"
echo -e "    Service status : $STATUS"
echo
echo "Useful commands:"
echo "  sv status dns-rotator"
echo "  sv restart dns-rotator"
echo "  tail -f $SERVICE_DIR/log/main/current"
echo "  cat ~/.dns-rotator.log"
echo
echo "Edit interval / DNS list in:"
echo "  ~/.config/dns-rotator/config"
echo
