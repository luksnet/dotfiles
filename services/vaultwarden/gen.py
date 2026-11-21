#!/usr/bin/env python3
"""Generator motywu Gruvbox Material dla sejfu WWW Vaultwardena.

Użycie:
    python3 -I gen.py styles.XXXX.css > user.vaultwarden.scss.hbs

styles.XXXX.css to arkusz sejfu WWW (link w kodzie strony logowania).
Skrypt bierze zmienne kolorów motywu ciemnego (.theme_dark) i paletę (:root),
przelicza je na Gruvbox Material i wypisuje nadpisania tylko dla .theme_dark,
więc motyw jasny zostaje bez zmian.

Mapowanie jak w stylu Twitcha (services/stylus):
  szarości (nasycenie < 15%) -> skala bg0..fg Gruvboxa według jasności
  niebieski Bitwardena       -> aqua #89b482
  pozostałe odcienie         -> red / orange / yellow / green / blue / purple Gruvboxa
"""
import colorsys
import re
import sys
from datetime import date

RAMP = [(0.0, "#141617"), (0.06, "#1d2021"), (0.10, "#282828"), (0.13, "#32302f"),
        (0.20, "#3c3836"), (0.25, "#45403d"), (0.45, "#7c6f64"), (0.70, "#a89984"),
        (0.90, "#d4be98"), (1.0, "#ddc7a1")]
# zakresy odcienia (stopnie) -> kolor Gruvboxa; niebieski Bitwardena idzie w aqua
TARGETS = [((0, 20), "#ea6962"), ((20, 40), "#e78a4e"), ((40, 65), "#d8a657"),
           ((65, 170), "#a9b665"), ((170, 200), "#7daea3"), ((200, 260), "#89b482"),
           ((260, 340), "#d3869b"), ((340, 361), "#ea6962")]


def h2rgb(h):
    h = h.lstrip("#")
    if len(h) == 3:
        h = "".join(c * 2 for c in h)
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def grey(l):
    for (a, ca), (b, cb) in zip(RAMP, RAMP[1:]):
        if l <= b:
            t = (l - a) / (b - a)
            x, y = h2rgb(ca), h2rgb(cb)
            return tuple(round(x[i] + (y[i] - x[i]) * t) for i in range(3))
    return h2rgb(RAMP[-1][1])


# Szarości Bitwardena są niebieskawe (nasycenie do ~50%), więc rozpoznajemy je po nazwie.
GREY_NAMES = re.compile(r"gray|background|secondary|shadow|text-(main|muted|contrast|alt2)|hover|transparent|white|black")


def gruvbox(rgb, force_grey=False):
    r, g, b = (c / 255 for c in rgb)
    h, l, s = colorsys.rgb_to_hls(r, g, b)
    if force_grey or s < 0.15 or l < 0.03 or l > 0.97:
        return grey(l)
    deg = h * 360
    target = next(t for (lo, hi), t in TARGETS if lo <= deg < hi)
    th, _, ts = colorsys.rgb_to_hls(*(c / 255 for c in h2rgb(target)))
    out = colorsys.hls_to_rgb(th, max(0.12, min(0.88, l)), min(ts, 0.6))
    return tuple(round(c * 255) for c in out)


def convert(name, value):
    """Zwraca przeliczoną wartość albo None, jeśli to nie jest kolor (np. var(...))."""
    v = value.strip()
    grey_ = bool(GREY_NAMES.search(name))
    m = re.fullmatch(r"(\d{1,3}) (\d{1,3}) (\d{1,3})", v)  # trójka RGB do rgb(var / alfa)
    if m:
        return "%d %d %d" % gruvbox(tuple(int(x) for x in m.groups()), grey_)
    m = re.fullmatch(r"#([0-9a-fA-F]{6}|[0-9a-fA-F]{3})", v)
    if m:
        return "#%02x%02x%02x" % gruvbox(h2rgb(m.group(1)), grey_)
    m = re.fullmatch(r"rgba?\((\d{1,3})[ ,]+(\d{1,3})[ ,]+(\d{1,3})\s*(?:[/,]\s*([\d.]+%?))?\)", v)
    if m:
        r, g, b = gruvbox(tuple(int(x) for x in m.groups()[:3]), grey_)
        alpha = m.group(4)
        return f"rgb({r} {g} {b} / {alpha})" if alpha else f"rgb({r} {g} {b})"
    return None


def block(css, selector):
    m = re.search(re.escape(selector) + r"\s*\{([^}]*)\}", css)
    return m.group(1) if m else ""


def main():
    css = open(sys.argv[1], encoding="utf-8").read()
    dark = dict(re.findall(r"(--[\w-]+)\s*:\s*([^;]+);", block(css, ".theme_dark")))
    palette = {}
    for name, value in re.findall(r"(--color-(?:gray|brand|green|red|orange|teal|coral|purple|pink|yellow|white|black)(?:-\d+)?)\s*:\s*(#[0-9a-fA-F]{3,6})\s*[;}]", css):
        palette.setdefault(name, value)

    lines = []
    for name, value in sorted({**palette, **dark}.items()):
        new = convert(name, value)
        if new is not None:
            lines.append(f"  {name}: {new} !important;")

    print(f"""/*
 * Vaultwarden: sejf WWW w kolorach Gruvbox Material (tylko motyw ciemny).
 * Wygenerowane przez services/vaultwarden/gen.py, {date.today().isoformat()}.
 * Plik: <katalog danych>/templates/scss/user.vaultwarden.scss.hbs
 */

.theme_dark {{
{chr(10).join(lines)}
  --tw-ring-offset-color: #282828 !important;
}}

.theme_dark ::selection {{
  background: #45403d;
  color: #d8a657;
}}""")


if __name__ == "__main__":
    main()
