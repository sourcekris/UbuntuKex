# Win-KeX on Ubuntu WSL2

Run Kali's **Win-KeX** (Windows + Kali Desktop EXperience) on **Ubuntu WSL2** with an **Xfce** desktop environment.

---

## Quick Start (Pre-installed)

Inside your Ubuntu WSL terminal:

| Mode | Command | Description |
|---|---|---|
| **Window Mode** (TigerVNC) | `kex` or `kex -s` | Dedicated window desktop with sound (`-s`) |
| **Enhanced Session Mode** (RDP) | `kex --esm -s` | High-performance Windows native RDP client (`mstsc.exe`) |
| **Seamless Mode** | `kex --sl -s` | Windows desktop integration with transparent Xfce panel |
| **Stop Server** | `kex stop` | Cleanly stops the running KeX server |
| **Kill All** | `kex kill` | Terminates all background KeX / VNC / RDP processes |
| **Status** | `kex --status` | Shows status of all session modes |
| **Change Password** | `kex --passwd` | Updates the TigerVNC connection password |

> **Tip**: While in Window Mode (TigerVNC), press **`F8`** to open the viewer menu (fullscreen toggle, clipboard, disconnect).

---

## Automated Installation (`install-kex.sh`)

To repeat this setup on a clean Ubuntu WSL2 instance:

```bash
cd /mnt/c/Users/sewid/source/repos/UbuntuKex
sudo bash ./install-kex.sh
```

### What the installer does:
1. Verifies WSL2 environment.
2. Installs required desktop & server packages (`xfce4`, `xfce4-terminal`, `xfce4-goodies`, `tigervnc-standalone-server`, `xrdp`, `dbus-x11`, `pulseaudio-utils`).
3. Downloads the official `kali-win-kex` debian package directly from the Kali Linux repository pool.
4. Installs and configures `kali-win-kex`.
5. Configures `/etc/sudoers.d/kali-win-kex` to allow passwordless helper commands (`wslg-sock`, `xrdpservice`, and `/tmp/.X11-unix` mount/unmount).
6. Configures `.xsession` to launch `startxfce4`.

---

## Restoring from Original Backup

If you ever need to restore Ubuntu back to its clean pre-KeX state:

```powershell
# 1. Terminate running Ubuntu
wsl --terminate Ubuntu

# 2. Unregister current instance (WARNING: deletes current rootfs)
wsl --unregister Ubuntu

# 3. Re-import from original backup
wsl --import Ubuntu "$env:LOCALAPPDATA\Packages\CanonicalGroupLimited.Ubuntu_79rhkp1fndgsc\LocalState" .\ubuntu-orig.tar.xz --version 2
```
