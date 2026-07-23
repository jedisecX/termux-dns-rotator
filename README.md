# Termux DNS Rotator

Automatic DNS rotating daemon for Termux.

Cycles through public DNS providers (Cloudflare, Quad9, AdGuard, OpenDNS, Control D, NextDNS) by rewriting `$PREFIX/etc/resolv.conf`.

- **No root required**
- Works only inside Termux (does not change Android system DNS)
- Optional `termux-services` integration for auto-start on boot
- Configurable interval and DNS list

---

## Quick Install

```bash
pkg update && pkg install git termux-services -y
git clone https://github.com/jedisecX/termux-dns-rotator.git
cd termux-dns-rotator
bash install.sh
```

That’s it. The rotator is now installed and running as a service.

---

## Manual Install

```bash
# Copy the binary
cp dns-rotator $PREFIX/bin/
chmod +x $PREFIX/bin/dns-rotator

# Optional: create config
mkdir -p $HOME/.config/dns-rotator
cp dns-rotator.conf $HOME/.config/dns-rotator/config
```

Then either:

**Option A – Run in background (simple)**
```bash
termux-wake-lock
nohup dns-rotator > /dev/null 2>&1 &
```

**Option B – Proper service (recommended)**
```bash
bash install.sh   # does everything including sv-enable
```

---

## Commands

```bash
# Check status
sv status dns-rotator

# Stop
sv down dns-rotator

# Start
sv up dns-rotator

# Restart / force rotation
sv restart dns-rotator

# View live log
tail -f $PREFIX/var/service/dns-rotator/log/current

# View rotation history
cat ~/.dns-rotator.log
```

---

## Configuration

Edit `~/.config/dns-rotator/config`:

```bash
# Rotation interval in seconds (default 300 = 5 min)
INTERVAL=300

# DNS servers (space-separated pairs)
DNS_LIST=(
  "1.1.1.1 1.0.0.1"                 # Cloudflare
  "8.8.8.8 8.8.4.4"                 # Google
  "9.9.9.9 149.112.112.112"         # Quad9
  "94.140.14.14 94.140.15.15"       # AdGuard
  "208.67.222.222 208.67.220.220"   # OpenDNS
  "76.76.2.0 76.76.10.0"            # Control D
  "45.90.28.0 45.90.30.0"           # NextDNS public
)
```

After editing, restart the service:

```bash
sv restart dns-rotator
```

---

## Uninstall

```bash
sv-disable dns-rotator 2>/dev/null
rm -rf $PREFIX/var/service/dns-rotator
rm -f $PREFIX/bin/dns-rotator
rm -rf $HOME/.config/dns-rotator
rm -f $HOME/.dns-rotator.log
```

---

## Notes

- This only affects Termux processes (`curl`, `dig`, Python, scrapers, etc.).
- Android system DNS (Chrome, apps, Wi-Fi) is **not** changed.
- For system-wide DNS rotation you need root + Magisk modules or a VPN-based DNS changer.
- Original resolv.conf is backed up to `$PREFIX/etc/resolv.conf.bak` on first run.

---

Made for the JediSec toolbox.
