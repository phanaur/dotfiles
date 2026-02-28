#!/usr/bin/env bash
# =============================================================================
# setup-wayland-arch.sh
# Instalación y configuración de entorno Wayland en Arch Linux / CachyOS
# Compositores: Niri, MangoWC, River
# =============================================================================

set -euo pipefail

# ── Colores ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }
header()  { echo -e "\n${BOLD}═══ $* ═══${NC}"; }

# ── Comprobaciones previas ────────────────────────────────────────────────────
[[ $EUID -eq 0 ]] && error "No ejecutes este script como root. Usa tu usuario normal."
command -v pacman &>/dev/null || error "Este script es para Arch Linux / CachyOS."

# ── Detectar AUR helper ───────────────────────────────────────────────────────
if command -v paru &>/dev/null; then
    AUR="paru"
elif command -v yay &>/dev/null; then
    AUR="yay"
else
    error "No se encontró paru ni yay. Instala uno de los dos primero."
fi
info "AUR helper detectado: $AUR"

# ── Preguntas iniciales ───────────────────────────────────────────────────────
header "Configuración inicial"

read -rp "¿Instalar Niri? [S/n]: " resp_niri
INSTALL_NIRI=true
[[ "${resp_niri,,}" == "n" ]] && INSTALL_NIRI=false

read -rp "¿Instalar MangoWC? [S/n]: " resp_mango
INSTALL_MANGO=true
[[ "${resp_mango,,}" == "n" ]] && INSTALL_MANGO=false

read -rp "¿Instalar River? [S/n]: " resp_river
INSTALL_RIVER=true
[[ "${resp_river,,}" == "n" ]] && INSTALL_RIVER=false


# ── 1. Actualización base ─────────────────────────────────────────────────────
header "1. Actualización del sistema"
sudo pacman -Syu --noconfirm
success "Sistema actualizado."

# ── 3. Paquetes base Wayland ──────────────────────────────────────────────────
header "2. Paquetes base Wayland"
sudo pacman -S --noconfirm --needed \
    waybar \
    mako \
    fuzzel \
    alacritty \
    xwayland-satellite \
    swaybg \
    playerctl \
    brightnessctl \
    grim \
    slurp \
    wl-clipboard \
    wl-clip-persist \
    wlr-randr \
    pipewire \
    wireplumber \
    pipewire-pulse \
    xdg-desktop-portal \
    xdg-desktop-portal-wlr \
    xdg-user-dirs \
    pavucontrol \
    bluez \
    bluez-utils \
    gnome-keyring
success "Paquetes base instalados."

# ── 4. Bluetooth ──────────────────────────────────────────────────────────────
header "3. Bluetooth"
sudo systemctl enable --now bluetooth
success "Servicio bluetooth activado."

# ── 5. Fuentes ────────────────────────────────────────────────────────────────
header "4. Fuentes"
sudo pacman -S --noconfirm --needed \
    ttf-jetbrains-mono-nerd \
    noto-fonts-emoji
success "Fuentes instaladas."

# ── 6. Niri ───────────────────────────────────────────────────────────────────
if $INSTALL_NIRI; then
    header "5. Niri"
    $AUR -S --noconfirm --needed niri xwayland-satellite dms-shell-bin
    mkdir -p ~/.config/niri/dms
    systemctl --user disable dms.service 2>/dev/null || true
    success "Niri + DMS instalados. Servicio DMS desactivado (se lanza desde config.kdl)."
fi

# ── 7. MangoWC ────────────────────────────────────────────────────────────────
if $INSTALL_MANGO; then
    header "6. MangoWC"
    # CachyOS tiene MangoWC en sus repos, en Arch puro usar el repo Terra o AUR
    if pacman -Si mangowc-git &>/dev/null 2>&1; then
        sudo pacman -S --noconfirm --needed mangowc-git
    else
        $AUR -S --noconfirm --needed mangowc-git
    fi
    success "MangoWC instalado."
fi

# ── 8. River ──────────────────────────────────────────────────────────────────
if $INSTALL_RIVER; then
    header "7. River"
    sudo pacman -S --noconfirm --needed river
    success "River instalado."
fi

# ── 10. Ficheros de configuración ─────────────────────────────────────────────
header "8. Ficheros de configuración"

USER_HOME="$HOME"
warn "Usando directorio home: $USER_HOME"

# ── Alacritty ─────────────────────────────────────────────────────────────────
mkdir -p ~/.config/alacritty
cat > ~/.config/alacritty/alacritty.toml << 'ALACRITTY_EOF'
[window]
padding = { x = 10, y = 10 }
decorations = "None"
opacity = 0.95

[font]
normal = { family = "JetBrainsMono Nerd Font", style = "Regular" }
bold   = { family = "JetBrainsMono Nerd Font", style = "Bold" }
size = 11.0

[colors.primary]
background = "#2f3242"
foreground = "#ffffff"

[colors.normal]
black   = "#383c4a"
red     = "#f53c3c"
green   = "#26A65B"
yellow  = "#ffbe61"
blue    = "#5294e2"
magenta = "#a05080"
cyan    = "#89b4fa"
white   = "#d3dae3"

[colors.bright]
black   = "#4b5162"
red     = "#f53c3c"
green   = "#26A65B"
yellow  = "#ffbe61"
blue    = "#5294e2"
magenta = "#a05080"
cyan    = "#89b4fa"
white   = "#ffffff"
ALACRITTY_EOF
success "~/.config/alacritty/alacritty.toml creado."

# ── Mako ──────────────────────────────────────────────────────────────────────
mkdir -p ~/.config/mako
cat > ~/.config/mako/config << 'MAKO_EOF'
background-color=#383c4a
text-color=#ffffff
border-color=#5294e2
border-radius=8
border-size=2
width=350
height=110
margin=10
padding=12
font=JetBrainsMono Nerd Font 11
default-timeout=5000
ignore-timeout=0

[urgency=high]
border-color=#f53c3c
default-timeout=0
MAKO_EOF
success "~/.config/mako/config creado."

# ── Fuzzel ────────────────────────────────────────────────────────────────────
mkdir -p ~/.config/fuzzel
cat > ~/.config/fuzzel/fuzzel.ini << 'FUZZEL_EOF'
[main]
font=JetBrainsMono Nerd Font:size=11
terminal=alacritty
layer=overlay
exit-on-keyboard-focus-loss=yes

[colors]
background=383c4add
text=ffffffff
match=5294e2ff
selection=5294e244
selection-text=ffffffff
border=5294e2ff

[border]
width=2
radius=8

[dmenu]
exit-immediately-if-empty=no
FUZZEL_EOF
success "~/.config/fuzzel/fuzzel.ini creado."

# ── Waybar compartido (Niri) ──────────────────────────────────────────────────
mkdir -p ~/.config/niri/waybar
cat > ~/.config/niri/waybar/config << 'WAYBAR_EOF'
{
    "layer": "top",
    "position": "top",
    "height": 36,
    "margin-top": 8,
    "margin-left": 12,
    "margin-right": 12,
    "spacing": 0,

    "modules-left": ["niri/workspaces", "cpu", "memory", "tray"],
    "modules-center": ["niri/window"],
    "modules-right": ["custom/playerctl", "pulseaudio", "bluetooth", "network", "battery", "clock"],

    "niri/workspaces": { "format": "{name}" },
    "niri/window": { "max-length": 60, "format": "{title}", "separate-outputs": true },

    "cpu": { "format": "󰯳 {usage}%", "interval": 2, "tooltip": false },
    "memory": { "format": "󰍛 {percentage}%", "interval": 2,
        "tooltip-format": "RAM: {used:0.1f}G / {total:0.1f}G" },
    "tray": { "icon-size": 15, "spacing": 6 },

    "custom/playerctl": {
        "format": "{icon}  {}",
        "return-type": "json",
        "max-length": 40,
        "exec": "playerctl -a metadata --format '{\"text\": \"{{artist}} ~ {{markup_escape(title)}}\", \"tooltip\": \"{{playerName}} : {{markup_escape(title)}}\", \"alt\": \"{{status}}\", \"class\": \"{{status}}\"}' -F 2>/dev/null",
        "on-click-middle": "playerctl play-pause",
        "on-click": "playerctl previous",
        "on-click-right": "playerctl next",
        "format-icons": { "Playing": "󰐊", "Paused": "󰏤", "Stopped": "󰓛" }
    },

    "pulseaudio": {
        "format": "{icon} {volume}%",
        "format-muted": "󰖁",
        "format-icons": { "default": ["", "", ""] },
        "on-click": "pavucontrol",
        "scroll-step": 5
    },

    "bluetooth": {
        "format": "{icon}",
        "format-icons": { "on": "󰂯", "off": "󰂲", "disabled": "󰂲", "connected": "󰂱" },
        "interval": 15,
        "tooltip-format": "{device_alias} — {status}",
        "on-click": "alacritty -e bluetoothctl"
    },

    "network": {
        "format-wifi": "  {essid}",
        "format-ethernet": "󰈀",
        "format-disconnected": "󰤭 Sin red",
        "tooltip-format-wifi": "{essid} ({signalStrength}%)\n{ipaddr}",
        "tooltip-format-ethernet": "{ifname}: {ipaddr}"
    },

    "battery": {
        "format": "{icon} {capacity}%",
        "format-charging": "󰂄 {capacity}%",
        "format-plugged": "󰚥 {capacity}%",
        "format-icons": ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"],
        "states": { "warning": 30, "critical": 15 }
    },

    "clock": {
        "format": "  {:%H:%M  %a %d}",
        "tooltip-format": "{calendar}",
        "calendar": {
            "mode": "month",
            "on-scroll": 1,
            "format": {
                "months":   "<span color='#bb9af7'><b>{}</b></span>",
                "days":     "<span color='#ffffff'><b>{}</b></span>",
                "weekdays": "<span color='#e0af68'><b>{}</b></span>",
                "today":    "<span color='#f7768e'><b>{}</b></span>"
            }
        }
    }
}
WAYBAR_EOF

cat > ~/.config/niri/waybar/style.css << 'WAYBAR_CSS_EOF'
@define-color bg          #383c4a;
@define-color bg-dark     #2f3242;
@define-color fg          #ffffff;
@define-color fg-dim      #7c818c;
@define-color blue        #5294e2;
@define-color green       #26A65B;
@define-color yellow      #ffbe61;
@define-color red         #f53c3c;

* {
    font-family: "JetBrainsMono Nerd Font", monospace;
    font-size: 12px;
    font-weight: 600;
    border: none;
    border-radius: 0;
    min-height: 0;
    transition: none;
}

window#waybar { background: transparent; color: @fg; }

#workspaces, #cpu, #memory, #tray, #custom-playerctl,
#pulseaudio, #bluetooth, #network, #battery, #clock {
    background-color: @bg;
    border-radius: 10px;
    padding: 2px 14px;
    margin: 5px 4px 2px 4px;
    color: @fg;
}

#workspaces { padding: 2px 6px; }
#workspaces button { color: @fg-dim; padding: 2px 8px; border-radius: 8px; background: transparent; font-size: 13px; }
#workspaces button:hover { background-color: @fg-dim; color: @bg; }
#workspaces button.active { background-color: @blue; color: @fg; border-radius: 8px; }
#workspaces button.urgent { color: @red; }

#window { background-color: @bg; border-radius: 10px; padding: 2px 18px; margin: 5px 4px 2px 4px; color: @fg; font-style: italic; }
window#waybar.empty #window { background: transparent; color: transparent; }

#tags { background: transparent; margin: 5px 4px 2px 4px; }
#tags button { background-color: @bg; color: @fg-dim; border-radius: 10px; padding: 2px 10px; margin: 0 2px; }
#tags button:not(.occupied):not(.focused) { font-size: 0; min-width: 0; min-height: 0; padding: 0; margin: 0; background: transparent; color: transparent; }
#tags button.occupied { background-color: @bg; color: @fg-dim; }
#tags button.focused { background-color: @blue; color: @fg; }
#tags button.urgent { background-color: @red; color: @fg; }

#custom-playerctl { color: @fg; }
#custom-playerctl.Paused { color: @fg-dim; }
#custom-playerctl.Stopped { opacity: 0.4; }
#pulseaudio { color: @fg; }
#pulseaudio.muted { background-color: #90b1b1; color: #2a5c45; }
#network { color: @fg; }
#network.disconnected { color: @red; }
#battery { color: @fg; }
#battery.charging, #battery.plugged { color: @green; }
#battery.warning:not(.charging) { color: @yellow; }
#battery.critical:not(.charging) { color: @fg; background-color: @red; animation: blink 0.5s linear infinite alternate; }
#tray { padding: 2px 10px; }
#tray > .needs-attention { -gtk-icon-effect: highlight; background-color: @red; border-radius: 10px; }
tooltip { background: @bg-dark; border-radius: 8px; color: @fg; }
@keyframes blink { to { background-color: @fg; color: @red; } }
WAYBAR_CSS_EOF
success "~/.config/niri/waybar/ configurado."

# ── Config Niri ───────────────────────────────────────────────────────────────
if $INSTALL_NIRI; then
    mkdir -p ~/.config/niri
    [[ -f ~/.config/niri/config.kdl ]] && cp ~/.config/niri/config.kdl ~/.config/niri/config.kdl.bak
    cat > ~/.config/niri/config.kdl << 'NIRI_EOF'
// Edita PLACEHOLDER por el nombre real de tu monitor (niri msg outputs)
input {
    keyboard {
	xkb {
            layout "es"
        }
    }
    touchpad { 
        tap; 
        natural-scroll;
        accel-speed 0.2; }
    focus-follows-mouse
}

output "PLACEHOLDER" {
    mode "1920x1080@60.000"
    scale 1.0
    position x=0 y=0
}

layout {
    gaps 14
    preset-column-widths {
        proportion 0.33333
        proportion 0.5
        proportion 0.66667
        proportion 0.99999
    }
    default-column-width { proportion 0.66667; }
    focus-ring {
        off
    }
    border {
        width 2
        active-color "#5294e2"
        inactive-color "#31324488"
    }
}

window-rule {
    geometry-corner-radius 10
    clip-to-geometry true
}

window-rule {
    match app-id="org.gnome.Calculator"
    match app-id="pavucontrol"
    match app-id="nm-connection-editor"
    open-floating true
}

prefer-no-csd

animations {
    slowdown 0.7
    window-open { duration-ms 250; curve "ease-out-cubic"; }
    window-close { duration-ms 200; curve "ease-out-cubic"; }
    window-movement { spring damping-ratio=0.8 stiffness=800 epsilon=0.0001; }
    horizontal-view-movement { spring damping-ratio=0.8 stiffness=800 epsilon=0.0001; }
}

//spawn-at-startup "waybar -c ~/.config/niri/waybar/config -s ~/.config/niri/waybar/style.css"
spawn-at-startup "dms" "run" "--session"
spawn-at-startup "mako"
spawn-at-startup "swaybg" "-m" "fill" "-i" "/usr/share/backgrounds/gnome/adwaita-l.jxl"
spawn-at-startup "xwayland-satellite"
spawn-at-startup "wl-clip-persist" "--clipboard" "regular"

binds {
    Mod+Return { spawn "alacritty"; }
    Mod+D      { spawn "fuzzel"; }
    Mod+Shift+Q { close-window; }
    Mod+Shift+E { quit; }

    Mod+H { focus-column-left; }
    Mod+L { focus-column-right; }
    Mod+J { focus-window-down; }
    Mod+K { focus-window-up; }

    Mod+Shift+H { move-column-left; }
    Mod+Shift+L { move-column-right; }
    Mod+Shift+J { move-window-down; }
    Mod+Shift+K { move-window-up; }

    Mod+R       { switch-preset-column-width; }
    Mod+F       { maximize-column; }
    Mod+Shift+F { fullscreen-window; }

    Mod+1 { focus-workspace 1; }
    Mod+2 { focus-workspace 2; }
    Mod+3 { focus-workspace 3; }
    Mod+4 { focus-workspace 4; }
    Mod+5 { focus-workspace 5; }
    Mod+Shift+1 { move-column-to-workspace 1; }
    Mod+Shift+2 { move-column-to-workspace 2; }
    Mod+Shift+3 { move-column-to-workspace 3; }
    Mod+Shift+4 { move-column-to-workspace 4; }
    Mod+Shift+5 { move-column-to-workspace 5; }

    Mod+WheelScrollRight { focus-column-right; }
    Mod+WheelScrollLeft  { focus-column-left; }

    Print       { screenshot; }
    Mod+Print   { screenshot-window; }

    XF86AudioRaiseVolume  { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"; }
    XF86AudioLowerVolume  { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
    XF86AudioMute         { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
    XF86MonBrightnessUp   { spawn "brightnessctl" "set" "10%+"; }
    XF86MonBrightnessDown { spawn "brightnessctl" "set" "10%-"; }
}

include "dms/cursor.kdl"
NIRI_EOF
    success "~/.config/niri/config.kdl creado."
fi

# ── Config MangoWC ────────────────────────────────────────────────────────────
if $INSTALL_MANGO; then
    mkdir -p ~/.config/mango/waybar

    cat > ~/.config/mango/config.conf << MANGO_EOF
xkb_rules_layout=es
repeat_rate=25
repeat_delay=600
numlockon=1

monitorrule=PLACEHOLDER,0.55,1,tile,0,1,0,0,1920,1080,60

gappih=10
gappiv=10
gappoh=12
gappov=12
borderpx=2
border_radius=10
no_radius_when_single=0
no_border_when_single=0

bordercolor=0x383c4aff
focuscolor=0x5294e2ff
urgentcolor=0xf53c3cff
scratchpadcolor=0x5294e244
rootcolor=0x2f3242ff

blur=0
shadows=1
shadow_only_floating=1
shadows_size=10
shadows_blur=15
shadows_position_x=0
shadows_position_y=3
shadowscolor=0x00000055
focused_opacity=1.0
unfocused_opacity=0.92

animations=1
layer_animations=1
animation_type_open=zoom
animation_type_close=fade
layer_animation_type_open=slide
layer_animation_type_close=slide
animation_fade_in=1
animation_fade_out=1
animation_duration_open=250
animation_duration_close=200
animation_duration_move=200
animation_duration_tag=250
animation_curve_open=0.46,1.0,0.29,1.1
animation_curve_move=0.46,1.0,0.29,1
animation_curve_tag=0.46,1.0,0.29,1
animation_curve_close=0.08,0.92,0,1

default_mfact=0.55
default_nmaster=1
smartgaps=0
new_is_master=1
scroller_default_proportion=0.5
scroller_focus_center=0
scroller_proportion_preset=0.33,0.5,0.66,1.0

sloppyfocus=1
warpcursor=0
focus_on_activate=1
xwayland_persistence=1
enable_hotarea=1
hotarea_size=10

env=XDG_CURRENT_DESKTOP,wlroots
env=XDG_SESSION_TYPE,wayland
env=XDG_SESSION_DESKTOP,wlroots
env=XCURSOR_SIZE,24
env=WLR_NO_HARDWARE_CURSORS,1
env=__GL_GSYNC_ALLOWED,0
env=__GL_VRR_ALLOWED,0
env=__NV_PRIME_RENDER_OFFLOAD,1
env=__GL_SYNC_TO_VBLANK,1
env=QT_WAYLAND_DISABLE_WINDOWDECORATION,1
cursor_size=24
clientside_decorations=0

windowrule=isfloating:1,appid:pavucontrol
windowrule=isfloating:1,appid:org.gnome.Calculator
windowrule=isfloating:1,appid:nm-connection-editor
windowrule=isfloating:1,appid:blueman-manager

bind=SUPER,Return,spawn,alacritty
bind=SUPER,d,spawn,fuzzel
bind=SUPER+SHIFT,q,killclient
bind=SUPER+SHIFT,e,quit
bind=SUPER,h,focusdir,left
bind=SUPER,l,focusdir,right
bind=SUPER,j,focusdir,down
bind=SUPER,k,focusdir,up
bind=SUPER+SHIFT,h,exchange_client,left
bind=SUPER+SHIFT,l,exchange_client,right
bind=SUPER+SHIFT,j,exchange_client,down
bind=SUPER+SHIFT,k,exchange_client,up
bind=SUPER,space,switch_layout
bind=SUPER,f,togglefullscreen
bind=SUPER,t,togglefloating
bind=SUPER,r,reload_config
bind=SUPER,o,toggleoverview
bind=SUPER,equal,setmfact,+10
bind=SUPER,minus,setmfact,-10
bind=SUPER,s,switch_proportion_preset
bind=SUPER+SHIFT,t,setlayout,tile
bind=SUPER+SHIFT,s,setlayout,scroller
bind=SUPER+SHIFT,m,setlayout,monocle
bind=SUPER+SHIFT,g,setlayout,grid
bind=SUPER,1,view,1
bind=SUPER,2,view,2
bind=SUPER,3,view,3
bind=SUPER,4,view,4
bind=SUPER,5,view,5
bind=SUPER,6,view,6
bind=SUPER,7,view,7
bind=SUPER,8,view,8
bind=SUPER,9,view,9
bind=SUPER+SHIFT,1,tag,1
bind=SUPER+SHIFT,2,tag,2
bind=SUPER+SHIFT,3,tag,3
bind=SUPER+SHIFT,4,tag,4
bind=SUPER+SHIFT,5,tag,5
bind=SUPER+SHIFT,6,tag,6
bind=SUPER+SHIFT,7,tag,7
bind=SUPER+SHIFT,8,tag,8
bind=SUPER+SHIFT,9,tag,9
bind=SUPER+CTRL,1,toggleview,1
bind=SUPER+CTRL,2,toggleview,2
bind=SUPER+CTRL,3,toggleview,3
bind=SUPER+CTRL,4,toggleview,4
bind=SUPER+CTRL,5,toggleview,5
bind=SUPER+ALT,1,toggletag,1
bind=SUPER+ALT,2,toggletag,2
bind=SUPER+ALT,3,toggletag,3
bind=SUPER+ALT,4,toggletag,4
bind=SUPER+ALT,5,toggletag,5
bind=NONE,XF86AudioRaiseVolume,spawn,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
bind=NONE,XF86AudioLowerVolume,spawn,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bind=NONE,XF86AudioMute,spawn,wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
bind=NONE,XF86MonBrightnessUp,spawn,brightnessctl set 10%+
bind=NONE,XF86MonBrightnessDown,spawn,brightnessctl set 10%-
bind=NONE,Print,spawn,$HOME/.config/mango/screenshot.sh
bind=SUPER,Print,spawn,$HOME/.config/mango/screenshot-area.sh

mousebind=SUPER,btn_left,moveresize,curmove
mousebind=SUPER,btn_right,moveresize,curresize

axisbind=SUPER,UP,focusstack,prev
axisbind=SUPER,DOWN,focusstack,next

exec-once=$HOME/.config/mango/autostart.sh
MANGO_EOF

    cat > ~/.config/mango/autostart.sh << 'AUTOSTART_EOF'
#!/bin/bash
set +e
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=wlroots
swaybg -m fill -i /usr/share/backgrounds/gnome/adwaita-l.jxl &
mako &
xwayland-satellite &
dms run &
#~/.config/mango/waybar/launch.sh &
AUTOSTART_EOF
    chmod +x ~/.config/mango/autostart.sh

    cat > ~/.config/mango/waybar/launch.sh << 'LAUNCH_EOF'
#!/bin/bash
until mmsg -g &>/dev/null; do
    sleep 0.5
done
FIFO=/tmp/mango-waybar-fifo
rm -f "$FIFO"
mkfifo "$FIFO"
mmsg -w > "$FIFO" &
waybar -c ~/.config/mango/waybar/config -s ~/.config/mango/waybar/style.css < "$FIFO"
LAUNCH_EOF
    chmod +x ~/.config/mango/waybar/launch.sh

    cat > ~/.config/mango/screenshot.sh << 'SS_EOF'
#!/bin/bash
mkdir -p ~/Imágenes
grim ~/Imágenes/screenshot-$(date +%Y%m%d-%H%M%S).png
SS_EOF
    chmod +x ~/.config/mango/screenshot.sh

    cat > ~/.config/mango/screenshot-area.sh << 'SSA_EOF'
#!/bin/bash
mkdir -p ~/Imágenes
grim -g "$(slurp)" ~/Imágenes/screenshot-$(date +%Y%m%d-%H%M%S).png
SSA_EOF
    chmod +x ~/.config/mango/screenshot-area.sh

    # Waybar config para MangoWC
    cat > ~/.config/mango/waybar/config << 'MWAYBAR_EOF'
{
    "layer": "top",
    "position": "top",
    "height": 36,
    "margin-top": 8,
    "margin-left": 12,
    "margin-right": 12,
    "spacing": 0,
    "modules-left": ["dwl/tags", "dwl/window"],
    "modules-center": [],
    "modules-right": ["cpu", "memory", "pulseaudio", "network", "battery", "clock", "tray"],
    "dwl/tags": { "num-tags": 9 },
    "dwl/window": { "max-length": 50 },
    "cpu": { "format": "󰯳 {usage}%", "interval": 2, "tooltip": false },
    "memory": { "format": "󰍛 {percentage}%", "interval": 2, "tooltip-format": "RAM: {used:0.1f}G / {total:0.1f}G" },
    "pulseaudio": { "format": "{icon} {volume}%", "format-muted": "󰖁", "format-icons": { "default": ["", "", ""] }, "on-click": "pavucontrol", "scroll-step": 5 },
    "network": { "format-wifi": "  {essid}", "format-ethernet": "󰈀", "format-disconnected": "󰤭", "tooltip-format-wifi": "{essid} ({signalStrength}%)\n{ipaddr}" },
    "battery": { "format": "{icon} {capacity}%", "format-charging": "󰂄 {capacity}%", "format-plugged": "󰚥 {capacity}%", "format-icons": ["󰁺","󰁻","󰁼","󰁽","󰁾","󰁿","󰂀","󰂁","󰂂","󰁹"], "states": { "warning": 30, "critical": 15 } },
    "clock": { "format": "  {:%H:%M  %a %d}", "tooltip-format": "{calendar}", "calendar": { "mode": "month", "on-scroll": 1, "format": { "months": "<span color='#bb9af7'><b>{}</b></span>", "days": "<span color='#ffffff'><b>{}</b></span>", "weekdays": "<span color='#e0af68'><b>{}</b></span>", "today": "<span color='#f7768e'><b>{}</b></span>" } } },
    "tray": { "icon-size": 15, "spacing": 6 }
}
MWAYBAR_EOF

    cp ~/.config/niri/waybar/style.css ~/.config/mango/waybar/style.css
    success "~/.config/mango/ configurado."
    warn "Edita monitorrule en ~/.config/mango/config.conf: cambia PLACEHOLDER por tu monitor."
fi

# ── Config River ──────────────────────────────────────────────────────────────
if $INSTALL_RIVER; then
    mkdir -p ~/.config/river/waybar

    cat > ~/.config/river/init << RIVER_EOF
#!/bin/sh

riverctl keyboard-layout es
riverctl border-width 2
riverctl border-color-focused 0x5294e2
riverctl border-color-unfocused 0x383c4a
riverctl border-color-urgent 0xf53c3c
riverctl set-option outer-padding 12
riverctl set-option view-padding 10
riverctl focus-follows-cursor normal
riverctl set-cursor-warp on-focus-change

riverctl rule-add -app-id pavucontrol float
riverctl rule-add -app-id "org.gnome.Calculator" float
riverctl rule-add -app-id nm-connection-editor float
riverctl rule-add -app-id blueman-manager float

riverctl map normal Super Return spawn alacritty
riverctl map normal Super D spawn fuzzel
riverctl map normal Super+Shift Q close
riverctl map normal Super+Shift E exit

riverctl map normal Super H focus-view left
riverctl map normal Super L focus-view right
riverctl map normal Super J focus-view down
riverctl map normal Super K focus-view up

riverctl map normal Super+Shift H swap left
riverctl map normal Super+Shift L swap right
riverctl map normal Super+Shift J swap down
riverctl map normal Super+Shift K swap up

riverctl map normal Super F toggle-fullscreen
riverctl map normal Super Space toggle-float
riverctl map normal Super Equal send-layout-cmd rivertile "main-ratio +0.05"
riverctl map normal Super Minus send-layout-cmd rivertile "main-ratio -0.05"
riverctl map normal Super Up    send-layout-cmd rivertile "main-location top"
riverctl map normal Super Down  send-layout-cmd rivertile "main-location bottom"
riverctl map normal Super Left  send-layout-cmd rivertile "main-location left"
riverctl map normal Super Right send-layout-cmd rivertile "main-location right"

for i in \$(seq 1 9); do
    tags=\$((1 << (\$i - 1)))
    riverctl map normal Super \$i set-focused-tags \$tags
    riverctl map normal Super+Shift \$i set-view-tags \$tags
    riverctl map normal Super+Control \$i toggle-focused-tags \$tags
    riverctl map normal Super+Alt \$i toggle-view-tags \$tags
done

riverctl map normal Super 0 set-focused-tags \$(((1 << 32) - 1))
riverctl map normal Super+Shift 0 set-view-tags \$(((1 << 32) - 1))

riverctl map-pointer normal Super BTN_LEFT move-view
riverctl map-pointer normal Super BTN_RIGHT resize-view

riverctl map normal None XF86AudioRaiseVolume  spawn "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
riverctl map normal None XF86AudioLowerVolume  spawn "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
riverctl map normal None XF86AudioMute         spawn "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
riverctl map normal None XF86MonBrightnessUp   spawn "brightnessctl set 10%+"
riverctl map normal None XF86MonBrightnessDown spawn "brightnessctl set 10%-"
riverctl map normal None Print spawn "$HOME/.config/river/screenshot.sh"
riverctl map normal Super Print spawn "$HOME/.config/river/screenshot-area.sh"

riverctl rule-add -app-id "*" ssd
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

riverctl default-layout rivertile
rivertile -main-location left -main-ratio 0.55 -main-count 1 &

dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=river
swaybg -m fill -i /usr/share/backgrounds/gnome/adwaita-l.jxl &
mako &
xwayland-satellite &
riverctl spawn "waybar -c $HOME/.config/river/waybar/config -s $HOME/.config/river/waybar/style.css"
RIVER_EOF
    chmod +x ~/.config/river/init

    cat > ~/.config/river/screenshot.sh << 'SS_EOF'
#!/bin/bash
mkdir -p ~/Imágenes
grim ~/Imágenes/screenshot-$(date +%Y%m%d-%H%M%S).png
SS_EOF
    chmod +x ~/.config/river/screenshot.sh

    cat > ~/.config/river/screenshot-area.sh << 'SSA_EOF'
#!/bin/bash
mkdir -p ~/Imágenes
grim -g "$(slurp)" ~/Imágenes/screenshot-$(date +%Y%m%d-%H%M%S).png
SSA_EOF
    chmod +x ~/.config/river/screenshot-area.sh

    # Waybar config para River
    cat > ~/.config/river/waybar/config << 'RWAYBAR_EOF'
{
    "layer": "top",
    "position": "top",
    "height": 36,
    "margin-top": 8,
    "margin-left": 12,
    "margin-right": 12,
    "spacing": 0,
    "modules-left": ["river/tags", "river/window"],
    "modules-center": [],
    "modules-right": ["cpu", "memory", "pulseaudio", "network", "battery", "clock", "tray"],
    "river/tags": { "num-tags": 9 },
    "river/window": { "max-length": 50 },
    "cpu": { "format": "󰯳 {usage}%", "interval": 2, "tooltip": false },
    "memory": { "format": "󰍛 {percentage}%", "interval": 2, "tooltip-format": "RAM: {used:0.1f}G / {total:0.1f}G" },
    "pulseaudio": { "format": "{icon} {volume}%", "format-muted": "󰖁", "format-icons": { "default": ["", "", ""] }, "on-click": "pavucontrol", "scroll-step": 5 },
    "network": { "format-wifi": "  {essid}", "format-ethernet": "󰈀", "format-disconnected": "󰤭", "tooltip-format-wifi": "{essid} ({signalStrength}%)\n{ipaddr}" },
    "battery": { "format": "{icon} {capacity}%", "format-charging": "󰂄 {capacity}%", "format-plugged": "󰚥 {capacity}%", "format-icons": ["󰁺","󰁻","󰁼","󰁽","󰁾","󰁿","󰂀","󰂁","󰂂","󰁹"], "states": { "warning": 30, "critical": 15 } },
    "clock": { "format": "  {:%H:%M  %a %d}", "tooltip-format": "{calendar}", "calendar": { "mode": "month", "on-scroll": 1, "format": { "months": "<span color='#bb9af7'><b>{}</b></span>", "days": "<span color='#ffffff'><b>{}</b></span>", "weekdays": "<span color='#e0af68'><b>{}</b></span>", "today": "<span color='#f7768e'><b>{}</b></span>" } } },
    "tray": { "icon-size": 15, "spacing": 6 }
}
RWAYBAR_EOF

    cp ~/.config/niri/waybar/style.css ~/.config/river/waybar/style.css
    success "~/.config/river/ configurado."
fi

# ── Resumen final ─────────────────────────────────────────────────────────────
header "Instalación completada"
echo ""
echo -e "${GREEN}Todo listo. Pasos siguientes:${NC}"
echo ""
if $INSTALL_NIRI; then
    echo "  Niri:"
    echo "    → Selecciona 'Niri' en el display manager"
    echo "    → Ejecuta 'niri msg outputs' y edita ~/.config/niri/config.kdl"
    echo "    → Reemplaza PLACEHOLDER por el nombre de tu monitor"
    echo ""
fi
if $INSTALL_MANGO; then
    echo "  MangoWC:"
    echo "    → Selecciona 'MangoWC' en el display manager"
    echo "    → Edita monitorrule en ~/.config/mango/config.conf"
    echo "    → Reemplaza PLACEHOLDER por el nombre de tu monitor"
    echo ""
fi
if $INSTALL_RIVER; then
    echo "  River:"
    echo "    → Selecciona 'River' en el display manager"
    echo ""
fi
echo -e "${BLUE}¡Disfruta!${NC}"
