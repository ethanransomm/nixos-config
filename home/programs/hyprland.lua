-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Ember Deep Hyprland config
-- Themed with the palette from DESIGN-BRIEF.md
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Ember Deep palette
local bg         = "rgba(10141fff)"   -- #10141f
local bgAlt      = "rgba(161c2bff)"   -- #161c2b
local surface    = "rgba(243b40ff)"   -- #243b40
local muted      = "rgba(3f4f7aff)"   -- #3f4f7a
local fgDim      = "rgba(9aa3b8ff)"   -- #9aa3b8
local fg         = "rgba(e5e9f2ff)"   -- #e5e9f2
local fgBright   = "rgba(f0ece2ff)"   -- #f0ece2
local rust       = "rgba(c14a1fff)"   -- #c14a1f
local rustDeep   = "rgba(8b2408ff)"   -- #8b2408
local rustPressed= "rgba(5a1705ff)"   -- #5a1705
local teal       = "rgba(4e8790ff)"   -- #4e8790l
local green      = "rgba(2f7a4fff)"   -- #2f7a4f
local maroon     = "rgba(7a2531ff)"   -- #7a2531
local sand       = "rgba(e6c384ff)"   -- #e6c384

-- ---------------------
-- ---- MONITORS ----
-- ---------------------
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080",   -- you can change to "preferred" if you prefer
    position = "0x0",
    scale    = "1.0",
}) 

-- ---------------------
-- ---- MY PROGRAMS ----
-- ---------------------
local terminal    = "kitty"
local fileManager = "dolphin"
local menu        = "rofi -show run"
local browser 	  = "firefox"

-- -------------------
-- ---- AUTOSTART ----
-- -------------------
hl.on("hyprland.start", function()
    hl.exec_cmd("$HOME/.local/bin/quickshell-bar")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("hyprpaper")
    -- add other startup commands here if needed
end)

-- -------------------------------
-- ---- ENVIRONMENT VARIABLES ----
-- -------------------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- -----------------------
-- ---- LOOK AND FEEL ----
-- -----------------------
hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 20,
        border_size = 2,

        col = {
            active_border   = { colors = { rust, teal }, angle = 45 },
            inactive_border = muted,
        },

        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = bgAlt,
        },

        blur = {
            enabled   = true,
            size      = 3,
            passes    = 1,
            vibrancy  = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})

-- Curves and animations (keep your existing ones)
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })
hl.curve("easy",           { type = "spring", mass = 1, stiffness = 238.1191, damping = 24.21279333 })

hl.animation({ leaf = "global",        enabled = true,  speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true,  speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true,  speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 4.1,  spring = "easy",         style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true,  speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true,  speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true,  speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true,  speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true,  speed = 7,    bezier = "quick" })

-- Layouts
hl.config({
    dwindle = { preserve_split = true },
    master  = { new_status = "master" },
    scrolling = { fullscreen_on_one_column = true },
})

-- Misc
hl.config({
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo   = false,
    },
})

-- Input (keyboard layout already set to GB)
hl.config({
    input = {
        kb_layout  = "gb",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = { natural_scroll = true

 },
    },
})

-- Gestures
hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

-- ---------------------
-- ---- KEYBINDINGS ----
-- ---------------------
local mainMod = "SUPER"
local fileManager = "dolphin" 

-- Exit Hyprland
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exit())

-- Terminal
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))

-- Kill active
hl.bind(mainMod .. " + Q", hl.dsp.window.close())

-- Lock screen
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))

-- File manager
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))

-- Toggle float
hl.bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }))

-- Clipboard history
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("quickshell ipc call panels toggle clipboard"))

-- Rofi menu
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))

-- Tap SUPER alone (release, no other key pressed meanwhile) -> launcher +
-- workspace overview, end-4 style. Holding SUPER for any other bind above
-- consumes the chord so this only fires on a bare tap.
hl.bind("SUPER_L", hl.dsp.exec_cmd("quickshell ipc call panels toggle overview"), { release = true })

-- Pseudo‑tile
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())

-- Toggle split (dwindle only)
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

-- Browser (if you have a `browser` variable)
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))

-- Focus movement (arrow keys) – dispatchers still use table syntax
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "d" }))

-- Move window
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "d" }))

-- Screenshots — saved to disk AND copied to the clipboard (so they show up
-- in the SUPER+V clipboard history) via `tee` splitting grim's stdout.
-- Full screen (captures all monitors – no jq needed)
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd(
    "mkdir -p ~/Pictures/Screenshots && " ..
    "grim - | tee ~/Pictures/Screenshots/full-$(date +%Y-%m-%d-%H%M%S).png | wl-copy && " ..
    "notify-send -a Screenshot 'Screenshot copied' 'Saved to ~/Pictures/Screenshots and copied to clipboard'"
))

-- Region selection
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(
    "mkdir -p ~/Pictures/Screenshots && " ..
    "grim -g \"$(slurp)\" - | tee ~/Pictures/Screenshots/region-$(date +%Y-%m-%d-%H%M%S).png | wl-copy && " ..
    "notify-send -a Screenshot 'Screenshot copied' 'Saved to ~/Pictures/Screenshots and copied to clipboard'"
))

-- Workspace switching (1-9)
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end
