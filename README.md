# dotfiles

Gruvbox Material na Arch + KDE Plasma 6: powłoka, Vim, terminale, kolory KDE,
Kvantum, tapety, ekran blokady, SDDM, GRUB i Plymouth. Do tego motywy usług
homelaba i awatary.

## Po świeżej instalacji

```bash
git clone <to repo> ~/Projekty/dotfiles
cd ~/Projekty/dotfiles
./install.sh
```

Bez argumentów pokazuje menu: wpisujesz numery modułów (np. `1 4 7-9`), żeby je
zaznaczyć lub odznaczyć, `a` zaznacza wszystko, `n` nic, Enter instaluje.
Moduły z sudo (pakiety, sddm, boot) są domyślnie odznaczone.

Bez menu:

```bash
./install.sh --lista                  # dostępne moduły
./install.sh bash vim kde-panel       # tylko te
./install.sh --wszystko               # domyślny zestaw (bez sudo)
./install.sh --dry-run tapety sddm    # tylko pokaż, co by się stało
bash kde/apply.sh panel blokada       # same ustawienia KDE, wybrane części
```

Istniejące pliki są przenoszone do `~/.dotfiles-backup/DATA/`, a na ich miejscu
powstają linki do repo, więc edycja `~/.bashrc` to edycja pliku w repo.

## Co gdzie jest

| Katalog | Zawartość | Trafia do |
|---|---|---|
| `home/` | `zshrc` i `bashrc` (prompt Gruvbox, fastfetch), `vimrc` | `~/.zshrc`, `~/.bashrc`, `~/.vimrc` |
| `config/` | fastfetch, alacritty, tmux, bat, btop, mpv, qBittorrent, Firefox, Obsidian, Kvantum (GruvboxAqua, GruvboxMaterial) | `~/.config/` (Firefox: domyślny profil, Obsidian: `.obsidian/snippets/` w sejfach) |
| `share/` | schematy kolorów KDE, Konsole | `~/.local/share/` |
| `wallpapers/` | tapety SVG + PNG 4K | `~/Obrazy/Tapety` |
| `kde/apply.sh` | moduły kde-*: kolory, kursor, ikony, Kvantum, czcionki, ramki okien, GTK, drugi panel (`panel2.js`), Kate, tapeta, ekran blokady, panel, zegar | ustawienia KDE |
| `system/` | SDDM, GRUB, Plymouth (sudo, kopie `*.bak-gruvbox`, `--cofnij` w boot) | `/etc`, `/boot`, `/usr/share` |
| `services/` | motyw Home Assistant, CSS Immich, motyw Brave | wklejane ręcznie w usługach |
| `avatars/` | awatary dla HA (Alex, psp) | wgrywane ręcznie |

Wtyczka gruvbox-material do Vima jest pobierana przez `install.sh`
(przypięta do sprawdzonego commita `11d779b`).

## W terminalu

- **fzf**: Ctrl+R historia, Ctrl+T pliki, Alt+C katalogi
- **eza**: `ls`, `ll`, `la`, `lt` (drzewo) z ikonami i stanem gita
- **bat**: `cat` z podświetlaniem, kolorowy `man`
- **zoxide**: `z luks` skacze do `~/Projekty/luks.net`, `zi` wybór z listy
- **tmux**: prefiks Ctrl+Spacja, `|` i `-` dzielą okno, `r` przeładowuje konfigurację
- **mpv**: OSD, pasek sterowania, konsola i statystyki (`i`) w Gruvbox, czcionka Hack; bez wtyczek
- **qBittorrent**: motyw w katalogu (`config.json` + `stylesheet.qss`), kolory stanów torrentów i logu, Hack w listach; włączyć przy zamkniętym programie
- **Firefox**: `userChrome.css` (karty, pasek adresu, menu) i `userContent.css` (strony `about:`); zwykłe strony bez zmian
- **Obsidian**: fragment CSS `gruvbox-hack`; po instalacji włącz w Ustawienia → Wygląd → Fragmenty CSS
- **Firefox** z motywem „System” bierze kolory z GTK, więc pasuje do KDE (moduł kde-gtk)

## Pakiety

- pacman: vim, git, alacritty, kvantum, fastfetch, plymouth, librsvg, wl-clipboard, ttf-hack, ttf-ibm-plex, zsh, zsh-completions, zsh-autosuggestions, zsh-syntax-highlighting, tmux, fzf, eza, bat, zoxide, btop, breeze-gtk, kde-gtk-config, ttf-nerd-fonts-symbols-mono
- AUR: gruvbox-plus-icon-theme, xcursor-simp1e-gruvbox-dark, xcursor-simp1e-gruvbox-light

Motywy Kvantum są w repo (przekolorowane kopie), więc `kvantum-theme-gruvbox-git` nie jest potrzebny.

## Usługi

- **Home Assistant**: `services/ha-gruvbox.yaml` do `config/themes/`, potem wybór motywu w profilu.
- **Immich**: `services/immich-gruvbox.css` w Administracja → Ustawienia → Motyw → własny CSS.
- **Brave**: `brave://extensions` → tryb dewelopera → „Załaduj rozpakowane” → `services/brave-gruvbox-material/`.
