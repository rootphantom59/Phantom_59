#!/data/data/com.termux/files/usr/bin/bash
# ==================================================================
#   PHANTOM - Ultimate Terminal Setup
#   Custom Figlet Banner + Zsh Theme + Oh My Zsh
#   Commands: pxhelp / pxbname / pxart / pxunstall
# ==================================================================

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
OBJ="$DIR"

G="\033[1;32m"
C="\033[1;36m"
R="\033[1;31m"
W="\033[1;37m"
Y="\033[1;33m"
RS="\033[0m"

IS_TERMUX=false

if [ -d "/data/data/com.termux/files/usr/" ]; then
    IS_TERMUX=true
fi

clear

echo -e "${C}══════════════════════════════════════════════${RS}"
echo -e "${G}           PHANTOM — INSTALLER${RS}"
echo -e "${C}══════════════════════════════════════════════${RS}"
echo

# ==============================================================
# 1. Check required files
# ==============================================================

REQUIRED_FILES=(
    "ANSI Phantom.flf"
    "art.sh"
    "bname.sh"
    "colors.properties"
    "help.sh"
    "termux.properties"
    "unstall.sh"
)

echo -e "${C}[*] Checking installer files...${RS}"

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$OBJ/$file" ]; then
        echo -e "${R}[×] Missing file: $file${RS}"
        echo
        echo -e "${Y}[!] Make sure all required files are in:${RS}"
        echo -e "${W}$DIR${RS}"
        exit 1
    fi
done

echo -e "${G}[+] All required files found.${RS}"
echo

# ==============================================================
# 2. User configuration
# ==============================================================

read -r -p "$(echo -e "${W}[?] Enter banner text (Figlet): ${RS}")" banner_text

if [ -z "$banner_text" ]; then
    banner_text="PHANTOM"
fi

read -r -p "$(echo -e "${W}[?] Enter prompt username: ${RS}")" prompt_user

if [ -z "$prompt_user" ]; then
    prompt_user="PHANTOM"
fi

prompt_user="${prompt_user^^}"
prompt_user="${prompt_user// /-}"

read -r -p "$(echo -e "${W}[?] Enter host name (default: termux): ${RS}")" prompt_host

if [ -z "$prompt_host" ]; then
    prompt_host="termux"
fi

echo
echo -e "${Y}[*] Banner : ${banner_text}${RS}"
echo -e "${Y}[*] Prompt : [${prompt_user}@${prompt_host}]${RS}"
echo

# ==============================================================
# 3. Install packages
# ==============================================================

echo -e "${C}[*] Installing required packages...${RS}"

if $IS_TERMUX; then

    pkg update -y >/dev/null 2>&1 || true

    pkg install -y \
        zsh \
        figlet \
        git \
        curl \
        ruby \
        ncurses-utils >/dev/null 2>&1

else

    if ! command -v sudo >/dev/null 2>&1; then
        echo -e "${R}[×] sudo is required on non-Termux systems.${RS}"
        exit 1
    fi

    sudo apt update -y >/dev/null 2>&1

    sudo apt install -y \
        zsh \
        figlet \
        git \
        curl \
        ruby \
        ncurses-bin >/dev/null 2>&1
fi

# ==============================================================
# 4. Install lolcat
# ==============================================================

if ! command -v lolcat >/dev/null 2>&1; then

    echo -e "${C}[*] Installing lolcat...${RS}"

    gem install lolcat >/dev/null 2>&1 || \
        echo -e "${Y}[!] lolcat installation failed. Plain colors will be used.${RS}"

fi

# ==============================================================
# 5. Oh My Zsh
# ==============================================================

echo -e "${C}[*] Installing Oh My Zsh...${RS}"

if [ ! -d "$HOME/.oh-my-zsh" ]; then

    git clone --depth=1 \
        https://github.com/ohmyzsh/ohmyzsh.git \
        "$HOME/.oh-my-zsh" >/dev/null 2>&1

else

    echo -e "${Y}[!] Oh My Zsh already installed.${RS}"

fi

# ==============================================================
# 6. Plugins
# ==============================================================

echo -e "${C}[*] Installing Zsh plugins...${RS}"

if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then

    git clone --depth=1 \
        https://github.com/zsh-users/zsh-autosuggestions \
        "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" \
        >/dev/null 2>&1

fi

if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then

    git clone --depth=1 \
        https://github.com/zsh-users/zsh-syntax-highlighting.git \
        "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" \
        >/dev/null 2>&1

fi

# ==============================================================
# 7. Install Figlet font
# ==============================================================

echo -e "${C}[*] Installing PHANTOM Figlet font...${RS}"

if $IS_TERMUX; then

    FIGLET_DIR="$PREFIX/share/figlet"

    mkdir -p "$FIGLET_DIR"

    cp "$OBJ/ANSI Phantom.flf" \
       "$FIGLET_DIR/PHANTOM.flf"

else

    FIGLET_DIR="/usr/share/figlet"

    sudo mkdir -p "$FIGLET_DIR"

    sudo cp "$OBJ/ANSI Phantom.flf" \
        "$FIGLET_DIR/PHANTOM.flf"

fi

# ==============================================================
# 8. Termux settings
# ==============================================================

if $IS_TERMUX; then

    echo -e "${C}[*] Installing Termux settings...${RS}"

    mkdir -p "$HOME/.termux"

    cp "$OBJ/colors.properties" \
       "$HOME/.termux/colors.properties"

    cp "$OBJ/termux.properties" \
       "$HOME/.termux/termux.properties"

    termux-reload-settings 2>/dev/null || true

fi

# ==============================================================
# 9. PHANTOM config
# ==============================================================

CONFIG_DIR="$HOME/.phantom"
BIN_DIR="$CONFIG_DIR/bin"
CONFIG_FILE="$CONFIG_DIR/config"

mkdir -p "$BIN_DIR"

cat > "$CONFIG_FILE" <<EOF
PHANTOM_USER="$prompt_user"
PHANTOM_HOST="$prompt_host"
PHANTOM_BANNER="$banner_text"
EOF

# ==============================================================
# 10. Copy command scripts
# ==============================================================

echo -e "${C}[*] Installing PHANTOM commands...${RS}"

cp "$OBJ/help.sh" \
   "$BIN_DIR/help.sh"

cp "$OBJ/bname.sh" \
   "$BIN_DIR/bname.sh"

cp "$OBJ/art.sh" \
   "$BIN_DIR/art.sh"

cp "$OBJ/unstall.sh" \
   "$BIN_DIR/unstall.sh"

chmod +x "$BIN_DIR/"*.sh

# ==============================================================
# 11. Banner script
# ==============================================================

BANNER_SCRIPT="$CONFIG_DIR/banner.sh"

cat > "$BANNER_SCRIPT" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash

CONFIG_FILE="$HOME/.phantom/config"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

clear

W="${COLUMNS:-80}"

if [ "$W" -lt 40 ]; then
    W=40
fi

BOX_TOP="╔$(printf '═%.0s' $(seq 1 $((W-2))))╗"
BOX_BOT="╚$(printf '═%.0s' $(seq 1 $((W-2))))╝"

if command -v figlet >/dev/null 2>&1; then

    BANNER=$(figlet \
        -d "$PREFIX/share/figlet" \
        -c \
        -f PHANTOM \
        -w "$W" \
        "$PHANTOM_BANNER" \
        2>/dev/null || true)

else

    BANNER="  $PHANTOM_BANNER"

fi

echo -e "\033[1;36m${BOX_TOP}\033[0m"

if command -v lolcat >/dev/null 2>&1; then

    echo "$BANNER" | lolcat -F 0.3 2>/dev/null || \
        echo -e "\033[1;32m${BANNER}\033[0m"

else

    echo -e "\033[1;32m${BANNER}\033[0m"

fi

printf "\n\033[1;37m   SYSTEM: \033[1;32mONLINE\033[1;37m   |   USER: \033[1;31m%s\033[0m\n" "$PHANTOM_USER"

printf "\033[1;37m   HOST   : \033[1;36m%s\033[0m\n" "$PHANTOM_HOST"

printf "\033[1;37m   TYPE '\033[1;33mpxhelp\033[1;37m' FOR COMMAND LIST\033[0m\n"

echo -e "\033[1;36m${BOX_BOT}\033[0m"
echo
EOF

chmod +x "$BANNER_SCRIPT"

# ==============================================================
# 12. PHANTOM Zsh theme
# ==============================================================

THEME_DIR="$HOME/.oh-my-zsh/custom/themes"

mkdir -p "$THEME_DIR"

THEME_FILE="$THEME_DIR/phantom.zsh-theme"

cat > "$THEME_FILE" <<'EOF'
autoload -U colors && colors
setopt prompt_subst

PHANTOM_CONFIG="$HOME/.phantom/config"

if [[ -f "$PHANTOM_CONFIG" ]]; then
    source "$PHANTOM_CONFIG"
fi

function parse_git_status() {

    git rev-parse --is-inside-work-tree &>/dev/null || return

    local branch

    branch=$(git symbolic-ref --short HEAD 2>/dev/null)

    if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then

        echo " %{$fg_bold[red]%}(${branch}*)%{$reset_color%}"

    else

        echo " %{$fg_bold[green]%}(${branch})%{$reset_color%}"

    fi
}

PROMPT='%{$fg_bold[red]%}╔══%{$fg_bold[green]%}[${PHANTOM_USER}@${PHANTOM_HOST}]%{$fg_bold[red]%}══%{$fg_bold[cyan]%}[%~]%{$fg_bold[red]%}$(parse_git_status)
%{$fg_bold[red]%}╚══➤ %{$reset_color%}'
EOF

# ==============================================================
# 13. .zshrc
# ==============================================================

ZSHRC="$HOME/.zshrc"

if [ -f "$ZSHRC" ]; then

    cp "$ZSHRC" "$ZSHRC.phantom.backup"

    echo -e "${Y}[!] Existing .zshrc backed up.${RS}"

fi

cat > "$ZSHRC" <<'EOF'
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="phantom"

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

# ==============================================================
# PHANTOM COMMANDS
# ==============================================================

alias pxhelp="bash $HOME/.phantom/bin/help.sh"
alias pxbname="bash $HOME/.phantom/bin/bname.sh"
alias pxart="bash $HOME/.phantom/bin/art.sh"
alias pxunstall="bash $HOME/.phantom/bin/unstall.sh"

# ==============================================================
# PHANTOM BANNER
# ==============================================================

bash "$HOME/.phantom/banner.sh"
EOF

# ==============================================================
# 14. Set Zsh as default shell
# ==============================================================

echo -e "${C}[*] Setting Zsh as default shell...${RS}"

if command -v zsh >/dev/null 2>&1; then

    chsh -s "$(command -v zsh)" >/dev/null 2>&1 || true

fi

# ==============================================================
# 15. Finish
# ==============================================================

echo
echo -e "${C}══════════════════════════════════════════════${RS}"
echo -e "${G}       [+] PHANTOM INSTALLED SUCCESSFULLY${RS}"
echo -e "${C}══════════════════════════════════════════════${RS}"
echo

echo -e "${W}[*] Banner   : ${banner_text}${RS}"
echo -e "${W}[*] Prompt   : [${prompt_user}@${prompt_host}]${RS}"
echo -e "${W}[*] Shell    : Zsh${RS}"
echo -e "${W}[*] Commands : pxhelp, pxbname, pxart, pxunstall${RS}"

echo
echo -e "${Y}[*] Restart Termux or run:${RS}"
echo -e "${G}    zsh${RS}"
echo