#!/bin/bash
# ==============================================================
# PHANTOM - Help Menu
# ==============================================================

r='\033[1;91m'
p='\033[1;95m'
y='\033[1;93m'
g='\033[1;92m'
n='\033[0m'
b='\033[1;94m'
c='\033[1;96m'

CONFIG_DIR="$HOME/.phantom"
CONFIG_FILE="$CONFIG_DIR/config"

# --------------------------------------------------------------
# Load PHANTOM config
# --------------------------------------------------------------
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# --------------------------------------------------------------
# Device information
# --------------------------------------------------------------
if command -v getprop >/dev/null 2>&1; then
    MODEL=$(getprop ro.product.model)
    VENDOR=$(getprop ro.product.manufacturer)
else
    MODEL=$(hostname)
    VENDOR=$(uname -o 2>/dev/null || uname -s)
fi

devicename="${VENDOR} ${MODEL}"

# --------------------------------------------------------------
# Disk usage
# --------------------------------------------------------------
THRESHOLD=100

check_disk_usage() {
    local total_size
    local used_size
    local disk_usage

    total_size=$(df -h "$HOME" | awk 'NR==2 {print $2}')
    used_size=$(df -h "$HOME" | awk 'NR==2 {print $3}')
    disk_usage=$(df "$HOME" | awk 'NR==2 {print $5}' | sed 's/%//g')

    if [ -z "$disk_usage" ]; then
        echo -e "${y}Disk usage: ${g}Unknown${n}"
        return
    fi

    if [ "$disk_usage" -ge "$THRESHOLD" ]; then
        echo -e "${r}WARN: ${y}Disk Full ${g}${disk_usage}% ${c}| U${g}${used_size} ${c}of T${g}${total_size}${n}"
    else
        echo -e "${y}Disk usage: ${g}${disk_usage}% ${c}| ${g}${used_size}${n}"
    fi
}

data=$(check_disk_usage)

# --------------------------------------------------------------
# PHANTOM ASCII Header
# --------------------------------------------------------------
echo -e "\n${c}   ░██████╗██╗░░██╗░█████╗░███╗░░██╗████████╗░█████╗░███╗░░░███╗${n}"
echo -e "${c}   ██╔════╝██║░░██║██╔══██╗████╗░██║╚══██╔══╝██╔══██╗████╗░████║${n}"
echo -e "${c}   ╚█████╗░███████║███████║██╔██╗██║░░░██║░░░███████║██╔████╔██║${n}"
echo -e "${c}   ░╚═══██╗██╔══██║██╔══██║██║╚████║░░░██║░░░██╔══██║██║╚██╔╝██║${n}"
echo -e "${c}   ██████╔╝██║░░██║██║░░██║██║░╚███║░░░██║░░░██║░░██║██║░╚═╝░██║${n}"
echo -e "${c}   ╚═════╝░╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░╚══╝░░░╚═╝░░░╚═╝░░╚═╝╚═╝░░░░░╚═╝${n}"

echo

# --------------------------------------------------------------
# PHANTOM information
# --------------------------------------------------------------
echo -e "${b}╭══ ${g}〄 ${y}ᴘʜᴀɴᴛᴏᴍ ${g}〄${n}"
echo -e "${b}┃❁ ${g}ᴅᴇᴠɪᴄᴇ: ${y}${devicename}${n}"
echo -e "${b}┃❁ ${g}ᴅɪꜱᴋ: ${y}${data}${n}"
echo -e "${b}╰┈➤ ${g}Hey ${y}${PHANTOM_USER:-FRIEND}${n}"

echo

# --------------------------------------------------------------
# Command Menu
# --------------------------------------------------------------
echo -e "${b}╭═════❂ ${g}ᴄᴏᴍᴍᴀɴᴅ ${b}❂═════⊷${n}"

echo -e "${b}┃ ${p}❏ ${g}pxhelp      ${p}[help menu]${n}"
echo -e "${b}┃ ${p}❏ ${g}pxbname     ${p}[change banner name/prompt]${n}"
echo -e "${b}┃ ${p}❏ ${g}pxart       ${p}[ascii art text generator]${n}"
echo -e "${b}┃ ${p}❏ ${g}pxunstall   ${p}[uninstall PHANTOM]${n}"

echo -e "${b}╰═══════════════════════⊷${n}"
echo