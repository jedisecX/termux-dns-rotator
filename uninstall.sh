#!/data/data/com.termux/files/usr/bin/bash
#
# Termux DNS Rotator - Uninstaller
#

set -euo pipefail

echo "[*] Stopping and removing dns-rotator service..."
sv-disable dns-rotator 2>/dev/null || true
sv down dns-rotator 2>/dev/null || true
rm -rf "$PREFIX/var/service/dns-rotator"

echo "[*] Removing binary..."
rm -f "$PREFIX/bin/dns-rotator"

echo "[*] Removing config and logs..."
rm -rf "$HOME/.config/dns-rotator"
rm -f "$HOME/.dns-rotator.log"

# Restore original resolv.conf if backup exists
if [[ -f "$PREFIX/etc/resolv.conf.bak" ]]; then
  echo "[*] Restoring original resolv.conf..."
  cp "$PREFIX/etc/resolv.conf.bak" "$PREFIX/etc/resolv.conf"
fi

echo "[+] Uninstall complete."
