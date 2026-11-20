#!/bin/bash
# Ustawia wygląd KDE Plasma 6. Bez argumentów robi wszystko, albo tylko wybrane części:
#   bash kde/apply.sh kolory kursor ikony kvantum czcionki okna gtk konsola kate tapeta blokada panel panel2
set -uo pipefail
PICTURES=$(xdg-user-dir PICTURES 2>/dev/null || echo ~/Pictures)
WALL=$PICTURES/Tapety/arch-gruvbox-4k.png
LOCK=$PICTURES/Tapety/gruvbox-kropki-4k.png
WSZYSTKIE="kolory kursor ikony kvantum czcionki okna gtk konsola kate tapeta blokada panel panel2"

kolory()  { plasma-apply-colorscheme GruvboxMaterial; }
kursor()  { plasma-apply-cursortheme Simp1e-Gruvbox-Dark; }
ikony()   { /usr/lib/plasma-changeicons Gruvbox-Plus-Dark; }
kvantum() { kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle kvantum; }
# interfejs IBM Plex Sans (pacman: ttf-ibm-plex), stała szerokość Hack
czcionki() {
    local ui="IBM Plex Sans,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
    local k
    for k in font menuFont toolBarFont; do
        kwriteconfig6 --notify --file kdeglobals --group General --key $k "$ui"
    done
    kwriteconfig6 --notify --file kdeglobals --group General --key smallestReadableFont "IBM Plex Sans,8,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
    kwriteconfig6 --notify --file kdeglobals --group General --key fixed "Hack,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
    kwriteconfig6 --notify --file kdeglobals --group WM --key activeFont "IBM Plex Sans,10,-1,5,500,0,0,0,0,0,0,0,0,0,0,1,Medium"
    qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true
}
# ramki okien Breeze: tytuł na środku, bez obwódki (kolory biorą się ze schematu)
okna() {
    kwriteconfig6 --file breezerc --group Common  --key OutlineIntensity OutlineOff
    kwriteconfig6 --file breezerc --group Windeco --key TitleAlignment AlignCenterFullWidth
    kwriteconfig6 --file breezerc --group Windeco --key DrawBackgroundGradient false
    kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key library org.kde.breeze
    kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key theme Breeze
    qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true
}
# aplikacje GTK (Firefox, GIMP): Breeze-GTK w kolorach schematu KDE
# (pacman: breeze-gtk kde-gtk-config)
gtk() {
    qdbus6 org.kde.GtkConfig /GtkConfig org.kde.GtkConfig.setGtkTheme Breeze >/dev/null 2>&1 \
        || kwriteconfig6 --file ~/.config/gtk-3.0/settings.ini --group Settings --key gtk-theme-name Breeze
}
konsola() { kwriteconfig6 --file konsolerc --group "Desktop Entry" --key DefaultProfile Gruvbox.profile; }
kate()    { kwriteconfig6 --file katerc --group "KTextEditor Renderer" --key "Color Theme" "gruvbox Dark"; }
tapeta()  { plasma-apply-wallpaperimage "$WALL"; }
blokada() {
    kwriteconfig6 --file kscreenlockerrc --group Greeter --key WallpaperPlugin org.kde.image
    for k in Image PreviewImage; do
        kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper \
            --group org.kde.image --group General --key $k "file://$LOCK"
    done
}
# pełna szerokość, przyklejony, 40 px; zegar Hack z krótką datą
panel() {
    qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '
panels().forEach(function(p){
  p.floating = false; p.lengthMode = "fill"; p.height = 40;
  p.widgets("org.kde.plasma.digitalclock").forEach(function(w){
    w.currentConfigGroup = ["Appearance"];
    w.writeConfig("showDate", true);
    w.writeConfig("dateDisplayFormat", "BesideTime");
    w.writeConfig("dateFormat", "custom");
    w.writeConfig("customDateFormat", "ddd d MMM");
    w.writeConfig("autoFontAndSize", false);
    w.writeConfig("fontFamily", "Hack");
    w.writeConfig("boldText", true);
    w.writeConfig("fontSize", 10);
  });
});' >/dev/null
}

# drugi monitor: panel z zadaniami z tego ekranu i zegarem (kde/panel2.js)
panel2() {
    qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript \
        "$(cat "$(dirname "$0")/panel2.js")"; echo
    panel   # ten sam wygląd zegara na obu panelach
}

CZESCI=${*:-$WSZYSTKIE}
for c in $CZESCI; do
    if [[ " $WSZYSTKIE " == *" $c "* ]]; then echo "kde: $c"; $c
    else echo "kde: nieznana część '$c' (są: $WSZYSTKIE)"; fi
done
