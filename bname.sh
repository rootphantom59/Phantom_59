#!/bin/bash
# ==============================================================
# PHANTOM - Change Banner / Prompt Name
# ==============================================================

clear

r='\033[1;91m'
g='\033[1;92m'
y='\033[1;93m'
c='\033[1;96m'
n='\033[0m'

E="${r}[×]${n}"

CONFIG_DIR="$HOME/.phantom"
CONFIG_FILE="$CONFIG_DIR/config"
ZSHRC="$HOME/.zshrc"
THEME="$HOME/.oh-my-zsh/custom/themes/phantom.zsh-theme"

# --------------------------------------------------------------
# Check PHANTOM installation
# --------------------------------------------------------------
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "\n ${r}[×] Error: PHANTOM is not installed yet.${n}"
    echo -e " ${y}[!] Run phantom_setup.sh first.${n}"
    exit 1
fi

# --------------------------------------------------------------
# Load config
# --------------------------------------------------------------
source "$CONFIG_FILE"

CURRENT_NAME="$PHANTOM_USER"

echo -e " ${c}[+] Current prompt name: ${g}${CURRENT_NAME}${n}"
echo

# --------------------------------------------------------------
# Get new name
# --------------------------------------------------------------
while true; do

    read -r -p "$(echo -e "${g}[${n}+${g}]──[${n}Enter New Name${g}]────►${n} ")" name

    echo

    # Empty check
    if [[ -z "$name" ]]; then
        echo -e " ${E} Name cannot be empty!"
        continue
    fi

    # Character check
    if [[ ! "$name" =~ ^[a-zA-Z0-9[:space:]-]+$ ]]; then
        echo -e " ${E} Invalid input!"
        echo -e " ${y}[!] Use letters, numbers, hyphens & spaces only.${n}"
        continue
    fi

    # Convert to uppercase
    name="${name^^}"

    # Replace spaces with hyphens
    name="${name// /-}"

    len=${#name}

    # Length check
    if [[ $len -ge 1 && $len -le 12 ]]; then
        break
    else
        echo -e " ${E} Name must be 1-12 characters."
        echo -e " ${y}[!] Current length: $len${n}"
    fi

done

# --------------------------------------------------------------
# Update PHANTOM config
# --------------------------------------------------------------
sed -i "s/^PHANTOM_USER=.*/PHANTOM_USER=\"$name\"/" "$CONFIG_FILE"

# --------------------------------------------------------------
# Update ZSH theme
# --------------------------------------------------------------
if [ -f "$THEME" ]; then

    # Replace the username value inside the theme
    sed -i "s/\$prompt_user/$name/g" "$THEME"

fi

# --------------------------------------------------------------
# Update .zshrc if required
# --------------------------------------------------------------
if [ -f "$ZSHRC" ]; then
    sed -i "s/PHANTOM_USER=\"$CURRENT_NAME\"/PHANTOM_USER=\"$name\"/g" "$ZSHRC"
fi

# --------------------------------------------------------------
# Update banner config
# --------------------------------------------------------------
BANNER_SCRIPT="$CONFIG_DIR/banner.sh"

if [ -f "$BANNER_SCRIPT" ]; then
    sed -i "s/$CURRENT_NAME/$name/g" "$BANNER_SCRIPT"
fi

# --------------------------------------------------------------
# Success
# --------------------------------------------------------------
echo -e " ${g}[+] Name successfully changed to: ${y}${name}${n}"
echo
echo -e " ${c}[!] Restart your terminal or run 'zsh' to see the changes.${n}"
echo