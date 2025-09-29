# 📦 Piko-Patch-Twitter  
*A simple Termux script for applying Piko patches to X/Twitter*

---

## ✅ Overview
This script automatically downloads and applies current latest release **Piko patches** and latest integrations apk to the Twitter (X) APK using **ReVanced CLI**.  
It also performs the following:
- ✅ **Checks if `revanced-cli.jar` and `aapt2` binary exist** in the script folder:
  - If missing → downloads the working versions.
  - If present → skips downloading.
  - Fetches latest current GitHub release  of `PikoPatches.jar` and `integrations.apk`
- ✅ Includes prompt and option for **"Bring Back Twitter Old Blue Icon"** with y/n selection

No root is required. Just make the script executable and run it (Requires copy to termux data dir of home for chmod rights if no root).

---

## ⚙️ Requirements
- **Android** with [Termux](https://github.com/termux/termux-app)
- `Twitter.apk` renamed that, Twitter.apk in same folder as script.
- `chmod +x` permission on the script either copy ~ (termux home) if no root or root run anywhere.

---

## 📥 Installation & Initial Setup
If both the script and `Twitter.apk` are in **`/sdcard/Download`**, move them to Termux home, give execute permission, and run:

```bash
mv /sdcard/Download/ResinousInMyX.sh ~ \
mv /sdcard/Download/Twitter.apk ~  \
chmod 0755 ResinousInMyX.sh  \
bash ~/ResinousInMyX.sh
```
or 1 line:
```bash
mv /sdcard/Download/ResinousInMyX.sh ~ && mv /sdcard/Download/Twitter.apk ~ && chmod 0755 ResinousInMyX.sh && bash ~/ResinousInMyX.sh

```
---

## 🔄 Future Updates
After the first patch, for new versions of Twitter, simply:
- Place the updated `Twitter.apk` in the script’s folder and
- Run:

```bash
./ResinousInMyX.sh
```
It will get latest patch jar and integrations APK. Then check if right version and size CLI jar exits already and download if needed same with aapt2 binary.
---

## 📝 Notes
- All Piko patches are included by default, **except the icon change**, which is optional via prompt.
- Script only downloads missing dependencies (`revanced-cli.jar` and `aapt2`)—this saves time and bandwidth.
- Ensure `Twitter.apk` **matches the name exactly**.
- Script fetches **latest Piko patches** and **Integrations APK** automatically.
- If you don’t have root, keep the script in Termux home (`~/`).

---

## 📌 Credits
- **Piko Patches** → [GitHub Repo](https://github.com/revanced/piko-patches)
- **ReVanced CLI** → [GitHub Repo](https://github.com/revanced/revanced-cli)
- **Custom AAPT2 (from ReVanced)** → [GitHub Repo](https://github.com/ReVanced/aapt2)
- **Termux** → [GitHub Repo](https://github.com/termux/termux-app)

---
