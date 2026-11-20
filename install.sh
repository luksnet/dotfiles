#!/bin/bash
# Dotfiles Gruvbox Material. Wybierasz, co zainstalować.
#
#   ./install.sh                     menu z listą do zaznaczenia
#   ./install.sh bash vim tapety     tylko wymienione moduły
#   ./install.sh --wszystko          wszystko poza modułami z sudo
#   ./install.sh --lista             pokaż moduły
#   --dry-run                        (z dowolnym z powyższych) tylko pokaż, co by się stało
#
# Pliki, które już istnieją, trafiają do ~/.dotfiles-backup/DATA/, a na ich miejscu
# powstają linki do repo. Powtórne uruchomienie niczego nie psuje.
set -euo pipefail

DOT=$(cd "$(dirname "$0")" && pwd)
BACKUP=~/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)
PICTURES=$(xdg-user-dir PICTURES 2>/dev/null || echo ~/Pictures)

# nazwa | opis | domyślnie zaznaczony (1/0)
MODULY=(
    "pakiety|pakiety pacman + AUR (sudo)|0"
    "zsh|~/.zshrc (prompt, wtyczki, fastfetch) i zsh jako powłoka|1"
    "bash|prompt Gruvbox i fastfetch w ~/.bashrc|1"
    "vim|~/.vimrc i motyw gruvbox-material|1"
    "fastfetch|konfiguracja fastfetch|1"
    "alacritty|motyw terminala Alacritty|1"
    "konsole|schematy i profil Konsole|1"
    "kolory|schematy kolorów KDE i motywy Kvantum (pliki)|1"
    "tmux|tmux w kolorach Gruvbox (prefiks Ctrl+Spacja)|1"
    "bat|bat (cat z podświetlaniem) w motywie gruvbox|1"
    "btop|btop w motywie Gruvbox Material|1"
    "tapety|tapety w ~/Obrazy/Tapety|1"
    "kde-kolory|KDE: włącz schemat Gruvbox Material|1"
    "kde-kursor|KDE: kursor Simp1e Gruvbox|1"
    "kde-ikony|KDE: ikony Gruvbox Plus|1"
    "kde-kvantum|KDE: styl widżetów Kvantum|1"
    "kde-czcionki|KDE: interfejs IBM Plex Sans, terminal Hack|1"
    "kde-okna|KDE: ramki okien (tytuł na środku, bez obwódki)|1"
    "kde-gtk|KDE: aplikacje GTK w kolorach Gruvbox|1"
    "kde-konsola|KDE: domyślny profil Konsole|1"
    "kde-kate|KDE: motyw Kate|1"
    "kde-tapeta|KDE: tapeta pulpitu (logo Arch)|1"
    "kde-blokada|KDE: tapeta ekranu blokady (kropki)|1"
    "kde-panel|KDE: panel na całą szerokość i zegar|1"
    "kde-panel2|KDE: panel na drugim monitorze|1"
    "sddm|ekran logowania SDDM (sudo)|0"
    "boot|GRUB i Plymouth (sudo)|0"
)
NAZWY=(); OPISY=(); WYBOR=()
for m in "${MODULY[@]}"; do
    IFS='|' read -r n o d <<<"$m"
    NAZWY+=("$n"); OPISY+=("$o"); WYBOR+=("$d")
done

DRY=0; ARGS=()
for a in "$@"; do
    case $a in
        --dry-run) DRY=1 ;;
        -h|--help) sed -n '2,11p' "$0"; exit 0 ;;
        --lista) for i in "${!NAZWY[@]}"; do printf '  %-12s %s\n' "${NAZWY[$i]}" "${OPISY[$i]}"; done; exit 0 ;;
        *) ARGS+=("$a") ;;
    esac
done

menu() {
    local in i
    while true; do
        clear 2>/dev/null || true
        echo "Co zainstalować? Wpisz numery, żeby zaznaczyć/odznaczyć (np. 1 4 7-9)."
        echo "a = wszystko, n = nic, Enter = instaluj, q = wyjdź"
        ((DRY)) && echo "(tryb --dry-run: nic nie zostanie zmienione)"
        echo
        for i in "${!NAZWY[@]}"; do
            printf ' %2d [%s] %-12s %s\n' $((i+1)) "$( ((WYBOR[i])) && echo x || echo ' ')" "${NAZWY[$i]}" "${OPISY[$i]}"
        done
        echo
        read -rp "> " in || exit 1
        case $in in
            "") return ;;
            q) exit 0 ;;
            a) for i in "${!WYBOR[@]}"; do WYBOR[i]=1; done ;;
            n) for i in "${!WYBOR[@]}"; do WYBOR[i]=0; done ;;
            *) for t in $in; do
                   if [[ $t =~ ^([0-9]+)-([0-9]+)$ ]]; then
                       for ((i=BASH_REMATCH[1]; i<=BASH_REMATCH[2]; i++)); do
                           ((i>=1 && i<=${#WYBOR[@]})) && WYBOR[i-1]=$((1-WYBOR[i-1]))
                       done
                   elif [[ $t =~ ^[0-9]+$ ]] && ((t>=1 && t<=${#WYBOR[@]})); then
                       WYBOR[t-1]=$((1-WYBOR[t-1]))
                   fi
               done ;;
        esac
    done
}

if ((${#ARGS[@]} == 0)); then
    [[ -t 0 ]] || { echo "Brak terminala: podaj moduły (./install.sh --lista)"; exit 1; }
    menu
elif [[ ${ARGS[0]} == --wszystko ]]; then
    : # domyślne zaznaczenie
else
    for i in "${!WYBOR[@]}"; do WYBOR[i]=0; done
    for a in "${ARGS[@]}"; do
        ok=0
        for i in "${!NAZWY[@]}"; do [[ ${NAZWY[$i]} == "$a" ]] && WYBOR[i]=1 && ok=1; done
        ((ok)) || { echo "Nieznany moduł: $a (lista: ./install.sh --lista)"; exit 1; }
    done
fi

run() { if ((DRY)); then echo "  [dry-run] $*"; else "$@"; fi; }

# link ŹRÓDŁO_W_REPO CEL
link() {
    local src=$DOT/$1 dst=$2
    if [[ -L $dst && $(readlink "$dst") == "$src" ]]; then
        echo "  ok      $dst"; return
    fi
    if [[ -e $dst || -L $dst ]]; then
        echo "  kopia   $dst -> $BACKUP/"
        run mkdir -p "$BACKUP"
        run mv "$dst" "$BACKUP/"
    fi
    echo "  link    $dst -> $1"
    run mkdir -p "$(dirname "$dst")"
    run ln -s "$src" "$dst"
}

m_pakiety() {
    run sudo pacman -S --needed vim git alacritty kvantum fastfetch plymouth librsvg wl-clipboard ttf-hack ttf-ibm-plex \
        zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting \
        tmux fzf eza bat zoxide btop breeze-gtk kde-gtk-config ttf-nerd-fonts-symbols-mono
    if command -v yay >/dev/null; then
        run yay -S --needed gruvbox-plus-icon-theme xcursor-simp1e-gruvbox-dark xcursor-simp1e-gruvbox-light
    else
        echo "  brak yay: zainstaluj z AUR gruvbox-plus-icon-theme i xcursor-simp1e-gruvbox-dark"
    fi
}
m_bash()      { link home/bashrc ~/.bashrc; }
m_zsh() {
    link home/zshrc ~/.zshrc
    if ! command -v zsh >/dev/null; then
        echo "  brak zsh: zaznacz też moduł pakiety albo: sudo pacman -S zsh"; return
    fi
    if [[ $(getent passwd "$USER" | cut -d: -f7) != */zsh ]]; then
        echo "  zmiana powłoki na zsh (chsh zapyta o hasło)"
        run chsh -s "$(command -v zsh)"
    fi
}
m_vim() {
    link home/vimrc ~/.vimrc
    local v=~/.vim/pack/themes/start/gruvbox-material
    if [[ ! -d $v ]]; then
        echo "  pobieram gruvbox-material"
        run git clone -q https://github.com/sainnhe/gruvbox-material.git "$v"
        run git -C "$v" checkout -q 11d779b   # sprawdzona wersja
    fi
}
m_fastfetch() { link config/fastfetch ~/.config/fastfetch; }
m_alacritty() { link config/alacritty/alacritty.toml ~/.config/alacritty/alacritty.toml; }
m_konsole() {
    local f
    for f in "$DOT"/share/konsole/*; do
        link "share/konsole/${f##*/}" ~/.local/share/konsole/"${f##*/}"
    done
}
m_kolory() {
    local f d
    for f in "$DOT"/share/color-schemes/*.colors; do
        link "share/color-schemes/${f##*/}" ~/.local/share/color-schemes/"${f##*/}"
    done
    for d in GruvboxAqua GruvboxMaterial; do link "config/Kvantum/$d" ~/.config/Kvantum/$d; done
    link config/Kvantum/kvantum.kvconfig ~/.config/Kvantum/kvantum.kvconfig
}
m_tmux()      { link config/tmux/tmux.conf ~/.config/tmux/tmux.conf; }
m_bat()       { link config/bat/config ~/.config/bat/config; }
m_btop()      { link config/btop/btop.conf ~/.config/btop/btop.conf; }
m_tapety()    { link wallpapers "$PICTURES/Tapety"; }
m_sddm()      { run sudo bash "$DOT/system/sddm-gruvbox.sh"; }
m_boot()      { run sudo bash "$DOT/system/boot/boot-gruvbox.sh"; }

KDE_CZESCI=()
for i in "${!NAZWY[@]}"; do
    ((WYBOR[i])) || continue
    n=${NAZWY[$i]}
    if [[ $n == kde-* ]]; then KDE_CZESCI+=("${n#kde-}"); continue; fi
    [[ $n == sddm || $n == boot ]] && continue   # na końcu
    echo "== $n"; "m_$n"
done
if ((${#KDE_CZESCI[@]})); then
    echo "== KDE: ${KDE_CZESCI[*]}"
    run bash "$DOT/kde/apply.sh" "${KDE_CZESCI[@]}"
fi
for i in "${!NAZWY[@]}"; do
    n=${NAZWY[$i]}
    [[ ($n == sddm || $n == boot) && ${WYBOR[$i]} == 1 ]] && { echo "== $n"; "m_$n"; }
done

echo
echo "Gotowe."
