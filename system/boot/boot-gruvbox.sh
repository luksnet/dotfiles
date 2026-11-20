#!/bin/bash
# Rozruch w stylu Gruvbox: motyw GRUB + ekran Plymouth z logo Arch, plus fastfetch.
# Uruchom:   sudo bash system/boot/boot-gruvbox.sh
# Cofnięcie: sudo bash system/boot/boot-gruvbox.sh --cofnij
set -euo pipefail
[[ $EUID -eq 0 ]] || { echo "Uruchom przez sudo: sudo bash $0"; exit 1; }

HERE=$(cd "$(dirname "$0")" && pwd)
GRUB_THEME_DIR=/boot/grub/themes/gruvbox
PLY_DIR=/usr/share/plymouth/themes/gruvbox-arch

if [[ ${1:-} == --cofnij ]]; then
    [[ -f /etc/default/grub.bak-gruvbox ]] && cp /etc/default/grub.bak-gruvbox /etc/default/grub
    [[ -f /etc/mkinitcpio.conf.bak-gruvbox ]] && cp /etc/mkinitcpio.conf.bak-gruvbox /etc/mkinitcpio.conf
    [[ -f /etc/kernel/cmdline.bak-gruvbox ]] && cp /etc/kernel/cmdline.bak-gruvbox /etc/kernel/cmdline
    rm -rf "$GRUB_THEME_DIR" "$PLY_DIR"
    mkinitcpio -P
    grub-mkconfig -o /boot/grub/grub.cfg
    echo "Przywrócono poprzedni rozruch (pakiety plymouth i fastfetch zostają zainstalowane)."
    exit 0
fi

# 1. Pakiety z oficjalnych repozytoriów
pacman -S --needed --noconfirm fastfetch plymouth

# 2. Kopie zapasowe (tylko przy pierwszym uruchomieniu)
[[ -f /etc/default/grub.bak-gruvbox ]] || cp /etc/default/grub /etc/default/grub.bak-gruvbox
[[ -f /etc/mkinitcpio.conf.bak-gruvbox ]] || cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.bak-gruvbox

# 3. Motyw GRUB
install -d "$GRUB_THEME_DIR"
install -m644 "$HERE"/grub/gruvbox/* "$GRUB_THEME_DIR"/
set_grub() {  # set_grub KLUCZ WARTOŚĆ: podmień albo dopisz linię w /etc/default/grub
    if grep -q "^$1=" /etc/default/grub; then sed -i "s|^$1=.*|$1=$2|" /etc/default/grub
    else echo "$1=$2" >> /etc/default/grub; fi
}
set_grub GRUB_THEME "\"$GRUB_THEME_DIR/theme.txt\""
set_grub GRUB_GFXMODE "1920x1080,auto"
# „splash” włącza ekran Plymouth zamiast komunikatów jądra
grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=.*splash' /etc/default/grub || \
    sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 splash"/' /etc/default/grub

# 4. Motyw Plymouth
install -d "$PLY_DIR"
install -m644 "$HERE"/plymouth/gruvbox-arch/* "$PLY_DIR"/

# 5. Hook plymouth w initramfs (zaraz po udev)
grep -q '^HOOKS=.*plymouth' /etc/mkinitcpio.conf || \
    sed -i 's/^HOOKS=(\(.*\)\budev\b/HOOKS=(\1udev plymouth/' /etc/mkinitcpio.conf
grep '^HOOKS=' /etc/mkinitcpio.conf

# 5b. Obraz jądra UKI (/boot/EFI/Linux/*.efi) ma wbudowany wiersz poleceń z
#     /etc/kernel/cmdline; GRUB_CMDLINE_LINUX_DEFAULT go nie zmienia.
if [[ -f /etc/kernel/cmdline ]]; then
    [[ -f /etc/kernel/cmdline.bak-gruvbox ]] || cp /etc/kernel/cmdline /etc/kernel/cmdline.bak-gruvbox
    for opt in quiet splash; do
        grep -qw "$opt" /etc/kernel/cmdline || sed -i "1s/\$/ $opt/" /etc/kernel/cmdline
    done
    echo "cmdline: $(cat /etc/kernel/cmdline)"
fi

# 6. Ustaw motyw i przebuduj initramfs oraz konfigurację GRUB
plymouth-set-default-theme gruvbox-arch
mkinitcpio -P
grub-mkconfig -o /boot/grub/grub.cfg

echo
echo "Gotowe. Nowy GRUB i ekran rozruchu zobaczysz przy następnym uruchomieniu."
echo "Gdyby coś było nie tak: sudo bash $0 --cofnij"
