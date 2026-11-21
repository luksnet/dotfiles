#!/usr/bin/env python3
"""Generuje układ pulpitu Steam Input dla nowego Steam Controllera (controller_triton).

Użycie: python3 -I gen.py > controller_triton_desktop_media.vdf

Myszka i przewijanie jak w zwykłym układzie pulpitu, do tego multimedia:
  prawy gładzik / prawa gałka  myszka (klik gładzika i prawy spust = lewy przycisk)
  lewy spust                   prawy przycisk myszy
  lewy gładzik                 kółko przewijania (krążenie palcem)
  lewa gałka                   strzałki (mpv: ±5 s w poziomie, ±1 min w pionie)
  krzyżak                      góra/dół głośność, lewo/prawo poprzedni/następny utwór
  A                            play/pauza (każdy odtwarzacz przez MPRIS, mpv też w tle)
  B                            Escape
  X                            F (mpv: pełny ekran)
  Y                            M (mpv: wyciszenie)
  bumpery                      Page Up / Page Down (mpv: poprzedni/następny rozdział)
  tylne dolne L / R            J / O (mpv: napisy / pasek postępu)
  menu / widok                 Escape / Tab
"""

def act(binding, kind="Full_Press", repeat=False):
    rep = ('\n\t\t\t\t\t\t"settings"\n\t\t\t\t\t\t{\n\t\t\t\t\t\t\t"repeat_rate"\t\t"120"\n\t\t\t\t\t\t}'
           if repeat else "")
    return (f'\t\t\t\t\t"{kind}"\n\t\t\t\t\t{{\n\t\t\t\t\t\t"bindings"\n\t\t\t\t\t\t{{\n'
            f'\t\t\t\t\t\t\t"binding"\t\t"{binding}"\n\t\t\t\t\t\t}}{rep}\n\t\t\t\t\t}}\n')

def inputs(mapping, kind="Full_Press", repeat=False):
    out = ""
    for name, binding in mapping.items():
        out += (f'\t\t\t"{name}"\n\t\t\t{{\n\t\t\t\t"activators"\n\t\t\t\t{{\n'
                f'{act(binding, kind, repeat)}\t\t\t\t}}\n\t\t\t}}\n')
    return out

def group(gid, mode, mapping=None, kind="Full_Press", repeat=False, settings=None):
    s = f'\t"group"\n\t{{\n\t\t"id"\t\t"{gid}"\n\t\t"mode"\t\t"{mode}"\n\t\t"description"\t\t""\n'
    if mapping is not None:
        s += f'\t\t"inputs"\n\t\t{{\n{inputs(mapping, kind, repeat)}\t\t}}\n'
    if settings:
        s += '\t\t"settings"\n\t\t{\n' + "".join(f'\t\t\t"{k}"\t\t"{v}"\n' for k, v in settings.items()) + '\t\t}\n'
    return s + "\t}\n"

groups = [
    group(0, "four_buttons", {"button_a": "key_press PLAY", "button_b": "key_press ESCAPE",
                              "button_x": "key_press F", "button_y": "key_press M"}),
    group(1, "scrollwheel", {"scroll_clockwise": "mouse_wheel SCROLL_DOWN",
                             "scroll_counterclockwise": "mouse_wheel SCROLL_UP",
                             "click": "mouse_button MIDDLE"}),
    group(2, "absolute_mouse", {"click": "mouse_button LEFT"}, kind="Soft_Press"),
    group(3, "dpad", {"dpad_north": "key_press UP_ARROW", "dpad_south": "key_press DOWN_ARROW",
                      "dpad_east": "key_press RIGHT_ARROW", "dpad_west": "key_press LEFT_ARROW"},
          kind="Start_Press", repeat=True),
    group(4, "trigger", {"edge": "mouse_button RIGHT"}),
    group(5, "trigger", {"edge": "mouse_button LEFT"}),
    group(6, "dpad", {"dpad_north": "key_press VOLUME_UP", "dpad_south": "key_press VOLUME_DOWN",
                      "dpad_east": "key_press NEXT_TRACK", "dpad_west": "key_press PREV_TRACK"}),
    group(7, "switches", {"button_menu": "key_press ESCAPE", "button_escape": "key_press TAB",
                          "left_bumper": "key_press PAGE_UP", "right_bumper": "key_press PAGE_DOWN",
                          "button_back_left": "key_press J", "button_back_right": "key_press O"}),
    group(8, "joystick_mouse", {}, settings={"output_joystick": "2"}),
]

print(f'''"controller_mappings"
{{
\t"version"\t\t"3"
\t"revision"\t\t"1"
\t"title"\t\t"Desktop + media (luks.net)"
\t"description"\t\t"Myszka, przewijanie i multimedia; mpv: gałka przewija, A play/pauza"
\t"creator"\t\t"0"
\t"controller_type"\t\t"controller_triton"
\t"localization"
\t{{
\t\t"english"
\t\t{{
\t\t\t"title"\t\t"Desktop + media (luks.net)"
\t\t\t"description"\t\t"Mouse, scrolling and media keys; mpv: stick seeks, A play/pause"
\t\t}}
\t}}
{"".join(groups)}\t"preset"
\t{{
\t\t"id"\t\t"0"
\t\t"name"\t\t"Default"
\t\t"group_source_bindings"
\t\t{{
\t\t\t"7"\t\t"switch active"
\t\t\t"0"\t\t"button_diamond active"
\t\t\t"1"\t\t"left_trackpad active"
\t\t\t"2"\t\t"right_trackpad active"
\t\t\t"3"\t\t"joystick active"
\t\t\t"4"\t\t"left_trigger active"
\t\t\t"5"\t\t"right_trigger active"
\t\t\t"6"\t\t"dpad active"
\t\t\t"8"\t\t"right_joystick active"
\t\t}}
\t}}
\t"settings"
\t{{
\t\t"left_trackpad_mode"\t\t"0"
\t\t"right_trackpad_mode"\t\t"0"
\t}}
}}''')
