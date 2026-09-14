-- Laptop screen
hl.monitor({
    output   = "eDP-1",
    mode     = "preferred",
    position = "0x0",
    scale    = 1,
})

-- HDMI output: extend to the right, show the same workspaces
-- (Hyprland shows each monitor's own workspaces  -  apps open on
-- whichever monitor is active/focused, so windows will appear on HDMI
-- when you move or open them there)
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "preferred",
    position = "1920x0",
    scale    = 1,
})

-- Fallback for any other connected output (e.g. DP-1, HDMI-A-2)
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})
