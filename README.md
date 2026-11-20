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
| `config/` | fastfetch, alacritty, Kvantum (GruvboxAqua, GruvboxMaterial) | `~/.config/` |
| `share/` | schematy kolorów KDE, Konsole | `~/.local/share/` |
| `wallpapers/` | tapety SVG + PNG 4K | `~/Obrazy/Tapety` |
| `kde/apply.sh` | moduły kde-*: kolory, kursor, ikony, Kvantum, Kate, tapeta, ekran blokady, panel, zegar | ustawienia KDE |
| `system/` | SDDM, GRUB, Plymouth (sudo, kopie `*.bak-gruvbox`, `--cofnij` w boot) | `/etc`, `/boot`, `/usr/share` |
| `services/` | motyw Home Assistant, CSS Immich, motyw Brave | wklejane ręcznie w usługach |
| `avatars/` | awatary dla HA (Alex, psp) | wgrywane ręcznie |

Wtyczka gruvbox-material do Vima jest pobierana przez `install.sh`
(przypięta do sprawdzonego commita `11d779b`).

## Pakiety

- pacman: vim, git, alacritty, kvantum, fastfetch, plymouth, librsvg, wl-clipboard, ttf-hack, zsh, zsh-completions, zsh-autosuggestions, zsh-syntax-highlighting
- AUR: gruvbox-plus-icon-theme, xcursor-simp1e-gruvbox-dark, xcursor-simp1e-gruvbox-light

Motywy Kvantum są w repo (przekolorowane kopie), więc `kvantum-theme-gruvbox-git` nie jest potrzebny.

## Usługi

- **Home Assistant**: `services/ha-gruvbox.yaml` do `config/themes/`, potem wybór motywu w profilu.
- **Immich**: `services/immich-gruvbox.css` w Administracja → Ustawienia → Motyw → własny CSS.
- **Brave**: `brave://extensions` → tryb dewelopera → „Załaduj rozpakowane” → `services/brave-gruvbox-material/`.
