#!/usr/bin/env bash
# ==============================================================================
# Script: install-kex.sh
# Purpose: Automated installation of Win-KeX (Kali Desktop Experience) on Ubuntu WSL2
# ==============================================================================

set -euo pipefail

# Ensure script is run with root privileges
if [ "$EUID" -ne 0 ]; then
    echo "[*] Requesting root privileges..."
    exec sudo bash "$0" "$@"
fi

# Text styles
BOLD='\033[1m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}${BOLD}=== Win-KeX Installer for Ubuntu WSL2 ===${NC}\n"

# 1. Verify WSL2 environment
echo -e "${BOLD}[1/6] Verifying WSL2 environment...${NC}"
if ! grep -qi "microsoft" /proc/version; then
    echo -e "${RED}[!] Error: This script must be run inside WSL (Windows Subsystem for Linux).${NC}"
    exit 1
fi

# 2. Update apt and install dependencies
echo -e "${BOLD}[2/6] Updating APT repositories and installing prerequisites...${NC}"
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y --no-install-recommends \
    xfce4 \
    xfce4-terminal \
    xfce4-goodies \
    tigervnc-standalone-server \
    xrdp \
    dbus-x11 \
    pulseaudio-utils \
    curl \
    wget \
    ca-certificates

# 3. Fetch latest kali-win-kex package
echo -e "${BOLD}[3/6] Fetching kali-win-kex package from Kali Linux repository...${NC}"
POOL_URL="http://http.kali.org/kali/pool/main/k/kali-win-kex/"
KEX_DEB_NAME=$(curl -sL "${POOL_URL}" | grep -o 'kali-win-kex_[0-9.]\+_amd64\.deb' | head -n 1)

if [ -z "${KEX_DEB_NAME}" ]; then
    # Fallback to known tested version
    KEX_DEB_NAME="kali-win-kex_3.1.4_amd64.deb"
fi

TEMP_DIR="/var/tmp/kex_install"
mkdir -p "${TEMP_DIR}"
DEB_PATH="${TEMP_DIR}/${KEX_DEB_NAME}"

echo -e "      Downloading ${CYAN}${KEX_DEB_NAME}${NC}..."
curl -L -o "${DEB_PATH}" "${POOL_URL}${KEX_DEB_NAME}"

# 4. Install Win-KeX package
echo -e "${BOLD}[4/6] Installing Win-KeX...${NC}"
dpkg -i "${DEB_PATH}" || apt-get install -f -y

# Clean up temporary download
rm -rf "${TEMP_DIR}"

# 5. Configure Sudoers permissions for Win-KeX
echo -e "${BOLD}[5/6] Configuring sudoers permissions for Win-KeX...${NC}"
SUDOERS_FILE="/etc/sudoers.d/kali-win-kex"
cat << 'EOF' > "${SUDOERS_FILE}"
# Win-KeX permissions for passwordless helper operations
%sudo ALL=(ALL) NOPASSWD: /usr/lib/win-kex/xrdp/xrdpservice
%sudo ALL=(ALL) NOPASSWD: /usr/lib/win-kex/wslg-sock/wslg-sock
%sudo ALL=(ALL) NOPASSWD: /usr/bin/mount, /bin/mount
%sudo ALL=(ALL) NOPASSWD: /usr/bin/umount, /bin/umount
EOF
chmod 0440 "${SUDOERS_FILE}"

# 6. Configure default XFCE session startup
echo -e "${BOLD}[6/6] Ensuring XFCE session startup configuration...${NC}"
if [ -n "${SUDO_USER:-}" ]; then
    USER_HOME=$(getent passwd "${SUDO_USER}" | cut -d: -f6)
    if [ -d "${USER_HOME}" ]; then
        echo "startxfce4" > "${USER_HOME}/.xsession"
        chown "${SUDO_USER}:${SUDO_USER}" "${USER_HOME}/.xsession"
    fi
fi

echo -e "\n${GREEN}${BOLD}✓ Win-KeX installation complete!${NC}\n"
echo -e "${BOLD}Usage Options:${NC}"
echo -e "  ${CYAN}kex${NC}             : Launch Win-KeX in Window mode (TigerVNC)"
echo -e "  ${CYAN}kex --win -s${NC}    : Launch Win-KeX in Window mode with Sound"
echo -e "  ${CYAN}kex --esm -s${NC}    : Launch Win-KeX in Enhanced Session Mode (RDP via mstsc.exe)"
echo -e "  ${CYAN}kex --sl -s${NC}     : Launch Win-KeX in Seamless mode (VcXsrv multiwindow)"
echo -e "  ${CYAN}kex stop${NC}        : Stop Win-KeX servers"
echo -e "  ${CYAN}kex kill${NC}        : Terminate all Win-KeX processes"
echo -e "  ${CYAN}kex --status${NC}    : Check status of running sessions"
echo ""
