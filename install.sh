#!/data/data/com.termux/files/usr/bin/bash
#
# Termux DNS Rotator - Installer
#

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
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
  echo -e "${YELLOW}[!] termux-services was just installed."
  echo -e "    You MUST fully close Termux and reopen it before the service will work.${NC}"
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

# Create service directory structure
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

# Try to enable + start
if sv-enable dns-rotator 2>/dev/null && sv up dns-rotator 2>/dev/null; then
  sleep 1
  STATUS=$(sv status dns-rotator 2>/dev/null || echo "unknown")
  echo
  echo -e "${GREEN}[+] Installation complete${NC}"
  echo -e "    Service status : $STATUS"
else
  echo
  echo -e "${YELLOW}[!] Could not start the service yet.${NC}"
  echo -e "${YELLOW}    This almost always means the termux-services daemon is not running.${NC}"
  echo
  echo -e "${CYAN}Do this now:${NC}"
  echo "  1. Completely close Termux (swipe it away from recent apps)"
  echo "  2. Open Termux again"
  echo "  3. Run:"
  echo
  echo -e "     ${GREEN}sv-enable dns-rotator${NC}"
  echo -e "     ${GREEN}sv up dns-rotator${NC}"
  echo
  echo -e "Then check with:  ${GREEN}sv status dns-rotator${NC}"
  echo
  echo -e "${YELLOW}Or use the fallback (works immediately):${NC}"
  echo "  termux-wake-lock"
  echo "  nohup dns-rotator > /dev/null 2>&1 &"
fi

echo
echo "Useful commands once running:"
echo "  sv status dns-rotator"
echo "  sv restart dns-rotator"
echo "  tail -f $SERVICE_DIR/log/main/current"
echo "  cat ~/.dns-rotator.log"
echo
echo "Edit interval / DNS list in:"
echo "  ~/.config/dns-rotator/config"
echo
