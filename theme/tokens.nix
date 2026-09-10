# Design tokens — the single source of truth for the *feel* of the desktop.
# Import this wherever you need a color, radius, gap, or animation curve so the
# whole rice stays cohesive. Colors mirror theme/ember-deep.yaml.
#
# Usage in a module:
#   let tokens = import ../../theme/tokens.nix; in
#   ... tokens.color.accent ... tokens.radius.md ...

rec {
  color = {
    bg        = "#10141f";  # base00 — page background
    bgAlt     = "#161c2b";  # base01 — bar, panels
    surface   = "#243b40";  # base02 — raised surfaces, selection
    muted     = "#3f4f7a";  # base03 — subtle/hover
    fgDim     = "#9aa3b8";  # base04 — secondary text
    fg        = "#e5e9f2";  # base05 — body text
    fgBright  = "#f0ece2";  # base06 — headers, warm off-white

    accent    = "#c14a1f";  # PRIMARY (active ws, focus border, primary btn)
    accentDeep = "#8b2408"; # mid rust (pill fills)
    accentPressed = "#5a1705";

    teal      = "#4e8790";  # secondary highlight / info
    green     = "#2f7a4f";  # success
    maroon    = "#7a2531";  # rare tint
    sand      = "#e6c384";  # warnings / highlights
  };

  # "Mixed edges" — subtle rounding, not big-radius floaty.
  radius = {
    sm = 6;
    md = 8;    # default for controls/windows
    lg = 12;   # cards, launcher
    pill = 20; # workspace pills only
  };

  gap = {
    xs = 4;
    sm = 6;
    md = 10;   # default window gaps
    lg = 16;
  };

  border = {
    width = 2;          # your mixed-edge border weight
    color = color.accent;
    colorInactive = color.surface;
  };

  # Restrained blur — floating windows only, not everywhere.
  blur = {
    enabled = true;
    size = 6;
    passes = 2;
  };

  # Fluid, eased motion. These beziers give the "settle, don't snap" feel.
  anim = {
    # smooth deceleration for windows/workspaces
    easeOut = "0.16, 1, 0.3, 1";
    # gentle standard curve
    standard = "0.25, 0.1, 0.25, 1";
    # slight overshoot for satisfying feedback (used sparingly)
    overshoot = "0.34, 1.56, 0.64, 1";
    speedFast = 4;   # deciseconds
    speedMed = 6;
    speedSlow = 8;
  };

  font = {
    mono = "JetBrainsMono Nerd Font";
    sans = "Inter";
    # Dedicated icon-only font, same one Quickshell's own Theme.qml uses
    # (Theme.font.icon) — JetBrainsMono Nerd Font's patched PUA glyphs for
    # some codepoints (0xf021 refresh, 0xf011 power confirmed) are a
    # different, uglier design than what Symbols Nerd Font ships at the same
    # codepoints. Anything rendering a Nerd Font icon glyph (not mixed with
    # real text in the same string) should use this, not `mono`.
    icon = "Symbols Nerd Font";
    sizeBar = 13;
    sizeUi = 11;
  };
}
