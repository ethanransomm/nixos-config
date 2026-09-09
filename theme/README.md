# Theme layer — "Ember Deep"

Built from your refined palette. This folder is the single source of truth for
the desktop's look and feel.

- `ember-deep.yaml` — base16 scheme (16 color slots). Stylix reads this and
  themes Kitty, GTK, SDDM, cursors, and app colors from it automatically.
- `tokens.nix` — the design tokens (colors, radii, gaps, border weight, blur,
  animation beziers, fonts). Hand-styled components (Hyprland, Waybar, rofi,
  hyprlock, swaync) import this so everything stays cohesive.

## The palette, by role

| Role            | Hex       | From your palette         |
|-----------------|-----------|---------------------------|
| base bg         | `#10141f` | navy, darkened            |
| bar / panels    | `#161c2b` | navy, mid-dark            |
| surface / sel   | `#243b40` | teal-slate (original)     |
| muted / hover   | `#3f4f7a` | navy, lifted              |
| secondary text  | `#9aa3b8` | derived                   |
| body text       | `#e5e9f2` | cool foreground (new)     |
| headers         | `#f0ece2` | warm off-white (new)      |
| PRIMARY accent  | `#c14a1f` | rust, capped (choice B)   |
| accent fill     | `#8b2408` | rust (original)           |
| accent pressed  | `#5a1705` | rust, deep                |
| success/green   | `#2f7a4f` | forest, brightened        |
| rare tint       | `#7a2531` | maroon, lifted            |

## Changing the whole look

- Swap one color: edit `tokens.nix` (for hand-styled parts) AND the matching
  slot in `ember-deep.yaml` (for Stylix-themed apps). Keep them in sync.
- The accent is `#c14a1f`. Change `color.accent` in tokens + `base08` in the
  yaml to re-tint every active/focus element at once.
