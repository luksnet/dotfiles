#!/bin/bash
# Ekran logowania SDDM w stylu Gruvbox Material (motyw Breeze z Plasmy 6).
# Uruchom:  sudo bash system/sddm-gruvbox.sh
# Cofnięcie: sudo bash system/sddm-gruvbox.sh --cofnij
set -euo pipefail
[[ $EUID -eq 0 ]] || { echo "Uruchom przez sudo: sudo bash $0"; exit 1; }

U=${SUDO_USER:-alex}
DOT=$(cd "$(dirname "$0")/.." && pwd)   # katalog dotfiles
WALL=/usr/share/wallpapers/gruvbox-kropki-4k.png

if [[ ${1:-} == --cofnij ]]; then
    rm -f /etc/sddm.conf.d/10-gruvbox.conf /usr/share/sddm/themes/breeze/theme.conf.user \
          /var/lib/sddm/.config/kdeglobals /var/lib/sddm/.config/kcminputrc \
          /usr/share/sddm/faces/$U.face.icon "$WALL" /usr/share/wallpapers/gruvbox-material.png
    echo "Przywrócono domyślny wygląd SDDM."
    exit 0
fi

# 1. Tapeta w miejscu, które użytkownik sddm może czytać (katalog domowy jest prywatny)
install -Dm644 "$DOT/wallpapers/gruvbox-kropki-4k.png" "$WALL"

# 2. Motyw Breeze: tło (siatka kropek), zegar, akcent pomarańczowy z tapety
cat > /usr/share/sddm/themes/breeze/theme.conf.user <<EOF
[General]
type=image
background=$WALL
color=#f1811e
showClock=true
fontSize=11
EOF

# 3. Wybór motywu i kursora
install -d /etc/sddm.conf.d
cat > /etc/sddm.conf.d/10-gruvbox.conf <<'EOF'
[Theme]
Current=breeze
CursorTheme=Simp1e-Gruvbox-Dark
CursorSize=24
EOF

# 4. Kolory Plasmy dla ekranu logowania (to samo robi „Zastosuj ustawienia Plazmy”)
install -d -o sddm -g sddm -m755 /var/lib/sddm/.config
install -o sddm -g sddm -m644 "$DOT/share/color-schemes/GruvboxMaterial.colors" \
        /var/lib/sddm/.config/kdeglobals
cat >> /var/lib/sddm/.config/kdeglobals <<'EOF'

[Icons]
Theme=Gruvbox-Plus-Dark
EOF
printf '[Mouse]\ncursorTheme=Simp1e-Gruvbox-Dark\ncursorSize=24\n' > /var/lib/sddm/.config/kcminputrc
chown sddm:sddm /var/lib/sddm/.config/kcminputrc

# 5. Awatar przy nazwie użytkownika
install -Dm644 "$DOT/avatars/ha-alex.png" /usr/share/sddm/faces/$U.face.icon

echo "Gotowe. Nowy wygląd zobaczysz po wylogowaniu albo restarcie."
