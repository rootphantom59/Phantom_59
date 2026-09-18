#!/bin/bash
# ==============================================================
# PHANTOM - Uninstaller
# ==============================================================

clear

r='\033[1;91m'
g='\033[1;92m'
y='\033[1;93m'
c='\033[1;96m'
n='\033[0m'

# --------------------------------------------------------------
# Confirmation
# --------------------------------------------------------------
echo -e " ${y}Do you want to restore the default terminal? (y/n)${n}"

read -r -p "$(echo -e "${g}[${n}+${g}]──[${n}Select${g}]────►${n} ")" choice

choice=$(printf '%s' "$choice" | tr '[:upper:]' '[:lower:]')

if [[ "$choice" != "y" && "$choice" != "yes" ]]; then
    echo -e "\n ${r}Cancelled.${n}"
    exit 1
fi

echo -e "\n ${c}Restoring default terminal...${n}"

# --------------------------------------------------------------
# Restore Bash
# --------------------------------------------------------------
if [ -d "/data/data/com.termux/files/usr/" ]; then

    chsh -s bash >/dev/null 2>&1 || true

else

    if command -v bash >/dev/null 2>&1; then
        sudo chsh -s "$(command -v bash)" "$USER" >/dev/null 2>&1 || true
    fi

fi

# --------------------------------------------------------------
# Remove PHANTOM configuration
# --------------------------------------------------------------
rm -rf "$HOME/.phantom"

# --------------------------------------------------------------
# Remove Zsh configuration installed by PHANTOM
# --------------------------------------------------------------
rm -rf "$HOME/.oh-my-zsh"

rm -f "$HOME/.zshrc"
rm -f "$HOME/.zsh_history"

# --------------------------------------------------------------
# Termux cleanup
# --------------------------------------------------------------
if [ -d "/data/data/com.termux/files/usr/" ]; then

    rm -f "$HOME/.termux/colors.properties"
    rm -f "$HOME/.termux/termux.properties"

    # Remove PHANTOM Figlet font
    rm -f "$PREFIX/share/figlet/PHANTOM.flf"

    termux-reload-settings 2>/dev/null || true

else

    # Linux cleanup
    sudo rm -f "/usr/share/figlet/PHANTOM.flf" 2>/dev/null || true

fi

# --------------------------------------------------------------
# Done
# --------------------------------------------------------------
echo
echo -e " ${g}[+] PHANTOM removed successfully!${n}"
echo -e " ${y}[!] Please restart your terminal.${n}"
echo