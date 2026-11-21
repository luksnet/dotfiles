// Generator stylu twitch-gruvbox.user.css.
// Użycie: otwórz twitch.tv w ciemnym motywie, F12 -> Konsola, wklej ten plik.
// Skrypt czyta wszystkie zmienne --color-* Twitcha, przelicza je na Gruvbox Material
// i kopiuje gotowy styl do schowka (albo wypisuje go w konsoli).
//
// Mapowanie:
//   szarości (nasycenie < 15%) -> skala bg0..fg Gruvboxa według jasności
//   fiolet Twitcha             -> aqua #89b482
//   pozostałe odcienie         -> red / orange / yellow / green / blue / purple Gruvboxa
// Jasność i przezroczystość zostają, zmienia się tylko odcień i nasycenie.
(() => {
  const cs = getComputedStyle(document.documentElement);
  const cv = document.createElement('canvas').getContext('2d');
  const parse = (v) => {
    if (!v || /none|transparent|gradient|url/.test(v)) return null;
    cv.fillStyle = '#010203';
    cv.fillStyle = v;
    const f = cv.fillStyle;
    if (f === '#010203' && v.toLowerCase() !== '#010203') return null;
    if (f.startsWith('#')) return [1, 3, 5].map((i) => parseInt(f.slice(i, i + 2), 16)).concat(1);
    const m = f.match(/rgba?\(([^)]+)\)/);
    if (!m) return null;
    const p = m[1].split(',').map(Number);
    return [p[0], p[1], p[2], p[3] ?? 1];
  };
  const toHsl = (r, g, b) => {
    r /= 255; g /= 255; b /= 255;
    const mx = Math.max(r, g, b), mn = Math.min(r, g, b);
    let h = 0, s = 0;
    const l = (mx + mn) / 2;
    if (mx !== mn) {
      const d = mx - mn;
      s = l > 0.5 ? d / (2 - mx - mn) : d / (mx + mn);
      h = mx === r ? (g - b) / d + (g < b ? 6 : 0) : mx === g ? (b - r) / d + 2 : (r - g) / d + 4;
      h *= 60;
    }
    return [h, s, l];
  };
  const toRgb = (h, s, l) => {
    const k = (n) => (n + h / 30) % 12, a = s * Math.min(l, 1 - l);
    const f = (n) => l - a * Math.max(-1, Math.min(k(n) - 3, Math.min(9 - k(n), 1)));
    return [f(0), f(8), f(4)].map((x) => Math.round(x * 255));
  };
  const hex = (c) => '#' + c.map((x) => x.toString(16).padStart(2, '0')).join('');
  const H = (s) => [1, 3, 5].map((i) => parseInt(s.slice(i, i + 2), 16));
  const ramp = [[0, '#141617'], [0.06, '#1d2021'], [0.10, '#282828'], [0.13, '#32302f'], [0.20, '#3c3836'],
    [0.25, '#45403d'], [0.45, '#7c6f64'], [0.70, '#a89984'], [0.90, '#d4be98'], [1, '#ddc7a1']].map(([l, c]) => [l, H(c)]);
  const grey = (l) => {
    for (let i = 1; i < ramp.length; i++) {
      if (l <= ramp[i][0]) {
        const [a, ca] = ramp[i - 1], [b, cb] = ramp[i], t = (l - a) / (b - a);
        return ca.map((x, j) => Math.round(x + (cb[j] - x) * t));
      }
    }
    return ramp.at(-1)[1];
  };
  const targets = [[[0, 20], '#ea6962'], [[20, 40], '#e78a4e'], [[40, 65], '#d8a657'], [[65, 170], '#a9b665'],
    [[170, 240], '#7daea3'], [[240, 290], '#89b482'], [[290, 340], '#d3869b'], [[340, 361], '#ea6962']];
  const map = ([r, g, b, a]) => {
    const [h, s, l] = toHsl(r, g, b);
    let out;
    if (s < 0.15 || l < 0.03 || l > 0.97) out = grey(l);
    else {
      const [th, ts] = toHsl(...H(targets.find(([[x, y]]) => h >= x && h < y)[1]));
      out = toRgb(th, Math.min(ts, 0.6), Math.max(0.12, Math.min(0.88, l)));
    }
    return a < 1 ? `rgba(${out.join(', ')}, ${+a.toFixed(2)})` : hex(out);
  };
  const lines = [];
  for (let i = 0; i < cs.length; i++) {
    const n = cs[i];
    if (!n.startsWith('--color-')) continue;
    const c = parse(cs.getPropertyValue(n).trim());
    if (c) lines.push(`    ${n}: ${map(c)} !important;`);
  }
  lines.sort();
  const css = `/* ==UserStyle==
@name           Twitch Gruvbox Material
@namespace      github.com/luksnet/dotfiles
@version        1.0.0
@description    Twitch w kolorach Gruvbox Material (aqua zamiast fioletu), czat w Hack.
@license        MIT
@preprocessor   default
==/UserStyle== */

@-moz-document domain("twitch.tv") {
  /* wygenerowane przez twitch-gruvbox-gen.js, ${new Date().toISOString().slice(0, 10)} */
  .tw-root--theme-dark,
  .tw-root--theme-dark body {
${lines.join('\n')}
  }

  .tw-root--theme-dark ::selection {
    background: #45403d !important;
    color: #d8a657 !important;
  }

  /* czat i pole wiadomości jak terminal */
  .tw-root--theme-dark .chat-line__message,
  .tw-root--theme-dark .chat-input textarea,
  .tw-root--theme-dark .chat-wysiwyg-input__editor {
    font-family: "Hack", monospace !important;
  }
}
`;
  copy?.(css);
  console.log(css);
  return `${lines.length} zmiennych; styl skopiowany do schowka (jeśli konsola na to pozwala)`;
})();
