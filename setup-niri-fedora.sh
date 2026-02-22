#!/usr/bin/env bash
# =============================================================================
# setup-niri-fedora.sh
# Instalación y configuración de Niri + entorno completo en Fedora
# Incluye: repos de terceros, drivers Nvidia (sobremesa), Niri, waybar,
#          mako, fuzzel, alacritty y ficheros de configuración base.
#
# Uso:
#   chmod +x setup-niri-fedora.sh
#   ./setup-niri-fedora.sh
#
# El script te preguntará si estás en el sobremesa (Nvidia) o en el portátil.
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

# ── Comprobaciones previas ───────────────────────────────────────────────────
[[ $EUID -eq 0 ]] && error "No ejecutes este script como root. Usa tu usuario normal (se pedirá sudo cuando sea necesario)."
command -v dnf &>/dev/null || error "Este script es para Fedora (dnf no encontrado)."

# Detectar versión de Fedora para compatibilidad DNF4/DNF5
FEDORA_VERSION=$(rpm -E %fedora)
info "Fedora ${FEDORA_VERSION} detectado."

# DNF5 es el default desde Fedora 41
if [[ "$FEDORA_VERSION" -ge 41 ]]; then
    DNF5=true
    info "Usando sintaxis DNF5."
else
    DNF5=false
    info "Usando sintaxis DNF4."
fi

# ── Preguntas iniciales ───────────────────────────────────────────────────────
header "Configuración inicial"

echo ""
echo "¿En qué equipo estás instalando esto?"
echo "  1) Sobremesa (i3-12100F + GTX 1080, necesita drivers Nvidia + workaround)"
echo "  2) Portátil  (i7-4712MQ + Intel HD 4600, sin drivers Nvidia propietarios)"
echo ""
read -rp "Elige [1/2]: " EQUIPO
case "$EQUIPO" in
    1) IS_DESKTOP=true;  info "Modo: Sobremesa con Nvidia." ;;
    2) IS_DESKTOP=false; info "Modo: Portátil con Intel." ;;
    *) error "Opción no válida." ;;
esac

echo ""
read -rp "¿Instalar Google Chrome? [s/N]: " INSTALL_CHROME
[[ "$INSTALL_CHROME" =~ ^[sS]$ ]] && CHROME=true || CHROME=false

echo ""
read -rp "¿Instalar Steam? [s/N]: " INSTALL_STEAM
[[ "$INSTALL_STEAM" =~ ^[sS]$ ]] && STEAM=true || STEAM=false

echo ""
read -rp "¿Instalar PyCharm Community (COPR)? [s/N]: " INSTALL_PYCHARM
[[ "$INSTALL_PYCHARM" =~ ^[sS]$ ]] && PYCHARM=true || PYCHARM=false

# ── 1. Actualizar el sistema ─────────────────────────────────────────────────
header "1. Actualización del sistema"
sudo dnf upgrade -y --refresh
success "Sistema actualizado."

# ── 2. Repositorios de terceros ──────────────────────────────────────────────
header "2. Repositorios de terceros"

# RPM Fusion Free + Nonfree
info "Instalando RPM Fusion Free y Nonfree..."
sudo dnf install -y \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VERSION}.noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VERSION}.noarch.rpm"

# RPM Fusion Tainted (libdvdcss y firmwares adicionales)
info "Instalando RPM Fusion Tainted (free + nonfree)..."
sudo dnf install -y rpmfusion-free-release-tainted rpmfusion-nonfree-release-tainted

# Actualizar metadatos (groupupdate core eliminado en DNF5)
if ! $DNF5; then
    sudo dnf groupupdate -y core
fi
success "RPM Fusion configurado."

# fedora-workstation-repositories (contiene definiciones de Chrome, etc.)
info "Instalando fedora-workstation-repositories..."
sudo dnf install -y fedora-workstation-repositories

# Google Chrome
if $CHROME; then
    info "Habilitando repositorio de Google Chrome..."
    if $DNF5; then
        sudo dnf config-manager setopt google-chrome.enabled=1
    else
        sudo dnf config-manager --set-enabled google-chrome
    fi
    sudo dnf install -y google-chrome-stable
    success "Google Chrome instalado."
fi

# Steam (via RPM Fusion nonfree, que ya está activado)
if $STEAM; then
    info "Instalando Steam..."
    sudo dnf install -y steam
    success "Steam instalado."
fi

# PyCharm Community (COPR phracek/PyCharm)
if $PYCHARM; then
    info "Habilitando COPR phracek/PyCharm..."
    sudo dnf copr enable -y phracek/PyCharm
    sudo dnf install -y pycharm-community
    success "PyCharm Community instalado."
fi

# ── 3. Codecs multimedia ─────────────────────────────────────────────────────
header "3. Codecs multimedia"
info "Instalando codecs desde RPM Fusion..."
if $DNF5; then
    # Fedora 41+ instala ffmpeg-free por defecto; hay que sustituirlo por el
    # ffmpeg completo de RPM Fusion (son paquetes conflictivos)
    info "Sustituyendo ffmpeg-free por ffmpeg completo de RPM Fusion..."
    sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing || \
        info "ffmpeg ya es la version completa, continuando."
    sudo dnf install -y --skip-unavailable \
        gstreamer1-plugins-ugly gstreamer1-plugins-bad-free \
        gstreamer1-plugins-bad-freeworld gstreamer1-plugin-openh264 \
        pipewire-codec-aptx \
        flac faac faad2 \
        x264 x265
else
    sudo dnf groupupdate -y multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
    sudo dnf groupupdate -y sound-and-video
fi
sudo dnf install -y libdvdcss
success "Codecs instalados."

# ── 4. Drivers Nvidia (solo sobremesa) ───────────────────────────────────────
if $IS_DESKTOP; then
    header "4. Drivers Nvidia (sobremesa)"
    info "Instalando drivers propietarios Nvidia desde RPM Fusion..."
    sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda

    info "Activando DRM kernel mode setting para Nvidia + Wayland..."
    sudo grubby --update-kernel=ALL --args="nvidia-drm.modeset=1 nvidia-drm.fbdev=1"

    info "Aplicando workaround de VRAM para Niri + Nvidia..."
    sudo mkdir -p /etc/nvidia/nvidia-application-profiles-rc.d
    sudo tee /etc/nvidia/nvidia-application-profiles-rc.d/50-niri-vram.json > /dev/null << 'NVIDIA_EOF'
{
    "rules": [
        {
            "pattern": {
                "feature": "procname",
                "matches": "niri"
            },
            "profile": "Limit Free Buffer Pool On Wayland Compositors"
        }
    ],
    "profiles": [
        {
            "name": "Limit Free Buffer Pool On Wayland Compositors",
            "settings": [
                {
                    "key": "GLVidHeapReuseRatio",
                    "value": 0
                }
            ]
        }
    ]
}
NVIDIA_EOF
    success "Drivers Nvidia y workaround de VRAM configurados."
    warn "IMPORTANTE: Tras el rebot, espera ~5 minutos antes de entrar en Niri para que akmod compile el módulo del kernel."
fi

# ── 5. Paquetes principales de Niri y entorno ────────────────────────────────
header "5. Instalación de Niri y herramientas"
sudo dnf install -y --skip-unavailable \
    niri \
    waybar \
    mako \
    fuzzel \
    alacritty \
    xwayland-satellite \
    gnome-keyring \
    libsecret \
    swaybg \
    playerctl \
    brightnessctl \
    grim \
    slurp \
    wl-clipboard \
    wlr-randr \
    pipewire \
    wireplumber \
    pipewire-pulseaudio \
    xdg-desktop-portal \
    xdg-desktop-portal-gnome \
    xdg-user-dirs

success "Niri y herramientas instalados."

# ── 6. Fuentes ───────────────────────────────────────────────────────────────
header "6. Fuentes"
sudo dnf install -y \
    jetbrains-mono-fonts \
    fontawesome-fonts \
    google-noto-emoji-fonts
success "Fuentes instaladas."

# ── 7. Crear ficheros de configuración ───────────────────────────────────────
header "7. Ficheros de configuración"

# Detectar nombre de monitor (se rellenará con placeholder)
MONITOR_NAME="PLACEHOLDER"
warn "El nombre de tu monitor se pondrá como '${MONITOR_NAME}' en el config de Niri."
warn "Después del primer arranque ejecuta 'niri msg outputs' para ver el nombre real y edita ~/.config/niri/config.kdl"

# ── Niri ──────────────────────────────────────────────────────────────────────
mkdir -p ~/.config/niri

if [[ -f ~/.config/niri/config.kdl ]]; then
    warn "Ya existe ~/.config/niri/config.kdl — se guarda como config.kdl.bak"
    cp ~/.config/niri/config.kdl ~/.config/niri/config.kdl.bak
fi

cat > ~/.config/niri/config.kdl << 'NIRI_EOF'
// ─────────────────────────────────────────────────────────────────────────────
// Configuración de Niri
// Edita "PLACEHOLDER" por el nombre real de tu monitor (niri msg outputs)
// ─────────────────────────────────────────────────────────────────────────────

// ── Input ─────────────────────────────────────────────────────────────────────
input {
    keyboard {
        xkb {
            layout "es"
            // variant "deadtilde"  // descomenta si la necesitas
        }
    }
    touchpad {
        tap
        natural-scroll
        accel-speed 0.2
    }
    focus-follows-mouse
}

// ── Outputs (pantallas) ───────────────────────────────────────────────────────
// Cambia PLACEHOLDER por el nombre real (ej: DP-1, HDMI-A-1, eDP-1)
output "PLACEHOLDER" {
    mode "1920x1080@60.000"
    scale 1.0
    position x=0 y=0
}

// ── Layout ────────────────────────────────────────────────────────────────────
layout {
    gaps 8
    center-focused-column "never"

    preset-column-widths {
        proportion 0.33333
        proportion 0.5
        proportion 0.66667
    }

    default-column-width { proportion 0.5; }

    focus-ring {
        width 2
        active-color "#89b4fa"
        inactive-color "#45475a"
    }

    border {
        off
    }
}

// ── Animaciones ───────────────────────────────────────────────────────────────
animations {
    slowdown 0.8
}

// ── Arranque de servicios ─────────────────────────────────────────────────────
spawn-at-startup "waybar"
spawn-at-startup "mako"
spawn-at-startup "swaybg" "-m" "fill" "-i" "/usr/share/backgrounds/gnome/adwaita-l.jxl"
spawn-at-startup "xwayland-satellite"

// ── Reglas de ventanas ────────────────────────────────────────────────────────
window-rule {
    match app-id="org.gnome.Calculator"
    match app-id="pavucontrol"
    match app-id="nm-connection-editor"
    open-floating true
}

// ── Atajos de teclado ─────────────────────────────────────────────────────────
binds {
    Mod+Return { spawn "alacritty"; }
    Mod+D      { spawn "fuzzel"; }
    Mod+Shift+Q { close-window; }
    Mod+Shift+E { quit; }

    // Foco
    Mod+H { focus-column-left; }
    Mod+L { focus-column-right; }
    Mod+J { focus-window-down; }
    Mod+K { focus-window-up; }

    // Mover
    Mod+Shift+H { move-column-left; }
    Mod+Shift+L { move-column-right; }
    Mod+Shift+J { move-window-down; }
    Mod+Shift+K { move-window-up; }

    // Tamaño y layout
    Mod+R       { switch-preset-column-width; }
    Mod+F       { maximize-column; }
    Mod+Shift+F { fullscreen-window; }

    // Workspaces
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

    // Scroll con rueda
    Mod+WheelScrollRight { focus-column-right; }
    Mod+WheelScrollLeft  { focus-column-left; }

    // Capturas
    Print       { screenshot; }
    Mod+Print   { screenshot-window; }

    // Audio (pipewire/wireplumber)
    XF86AudioRaiseVolume  { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"; }
    XF86AudioLowerVolume  { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
    XF86AudioMute         { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }

    // Brillo (útil en portátil)
    XF86MonBrightnessUp   { spawn "brightnessctl" "set" "10%+"; }
    XF86MonBrightnessDown { spawn "brightnessctl" "set" "10%-"; }
}
NIRI_EOF
success "~/.config/niri/config.kdl creado."

# ── Waybar ────────────────────────────────────────────────────────────────────
mkdir -p ~/.config/waybar

cat > ~/.config/waybar/config << 'WAYBAR_EOF'
{
    "layer": "top",
    "position": "top",
    "height": 30,
    "spacing": 4,

    "modules-left": ["niri/workspaces", "niri/window"],
    "modules-center": ["clock"],
    "modules-right": ["pulseaudio", "network", "battery", "tray", "custom/power"],

    "niri/workspaces": { "format": "{name}" },
    "niri/window": { "max-length": 50 },

    "clock": {
        "format": "{:%H:%M  %d/%m/%Y}",
        "tooltip-format": "<big>{:%A %d de %B de %Y}</big>"
    },
    "pulseaudio": {
        "format": "  {volume}%",
        "format-muted": "  mute",
        "on-click": "pavucontrol"
    },
    "network": {
        "format-wifi": "  {essid}",
        "format-ethernet": "  {ipaddr}",
        "format-disconnected": "  sin red",
        "tooltip-format": "{ifname}: {ipaddr}/{cidr}"
    },
    "battery": {
        "format": "{icon}  {capacity}%",
        "format-icons": ["", "", "", "", ""],
        "format-charging": "  {capacity}%",
        "states": { "warning": 30, "critical": 15 }
    },
    "tray": { "spacing": 8 },
    "custom/power": {
        "format": "⏻",
        "on-click": "niri msg action quit"
    }
}
WAYBAR_EOF

cat > ~/.config/waybar/style.css << 'WAYBAR_CSS_EOF'
* {
    font-family: "JetBrains Mono", monospace;
    font-size: 13px;
}

window#waybar {
    background-color: rgba(30, 30, 46, 0.9);
    color: #cdd6f4;
    border-bottom: 2px solid #89b4fa;
}

#workspaces button {
    padding: 0 8px;
    color: #6c7086;
    background: transparent;
    border-radius: 4px;
}

#workspaces button.active {
    color: #cdd6f4;
    background-color: #313244;
}

#clock, #battery, #pulseaudio, #network, #tray, #custom-power {
    padding: 0 12px;
    color: #cdd6f4;
}

#battery.warning { color: #fab387; }
#battery.critical { color: #f38ba8; }
WAYBAR_CSS_EOF
success "~/.config/waybar/ configurado."

# ── Mako ──────────────────────────────────────────────────────────────────────
mkdir -p ~/.config/mako

cat > ~/.config/mako/config << 'MAKO_EOF'
background-color=#1e1e2e
text-color=#cdd6f4
border-color=#89b4fa
border-radius=8
border-size=2
width=350
height=110
margin=10
padding=12
font=JetBrains Mono 11
default-timeout=5000
ignore-timeout=0

[urgency=high]
border-color=#f38ba8
default-timeout=0
MAKO_EOF
success "~/.config/mako/config creado."

# ── Fuzzel ────────────────────────────────────────────────────────────────────
mkdir -p ~/.config/fuzzel

cat > ~/.config/fuzzel/fuzzel.ini << 'FUZZEL_EOF'
[main]
font=JetBrains Mono:size=11
terminal=alacritty
layer=overlay
exit-on-keyboard-focus-loss=yes

[colors]
background=1e1e2edd
text=cdd6f4ff
match=89b4faff
selection=313244ff
selection-text=cdd6f4ff
border=89b4faff

[border]
width=2
radius=8

[dmenu]
exit-immediately-if-empty=no
FUZZEL_EOF
success "~/.config/fuzzel/fuzzel.ini creado."

# ── Alacritty ─────────────────────────────────────────────────────────────────
mkdir -p ~/.config/alacritty

cat > ~/.config/alacritty/alacritty.toml << 'ALACRITTY_EOF'
[window]
padding = { x = 10, y = 10 }
decorations = "None"
opacity = 0.95

[font]
normal = { family = "JetBrains Mono", style = "Regular" }
bold   = { family = "JetBrains Mono", style = "Bold" }
size = 11.0

# Tema Catppuccin Mocha (coordina con waybar y mako)
[colors.primary]
background = "#1e1e2e"
foreground = "#cdd6f4"

[colors.normal]
black   = "#45475a"
red     = "#f38ba8"
green   = "#a6e3a1"
yellow  = "#f9e2af"
blue    = "#89b4fa"
magenta = "#f5c2e7"
cyan    = "#94e2d5"
white   = "#bac2de"

[colors.bright]
black   = "#585b70"
red     = "#f38ba8"
green   = "#a6e3a1"
yellow  = "#f9e2af"
blue    = "#89b4fa"
magenta = "#f5c2e7"
cyan    = "#94e2d5"
white   = "#a6adc8"
ALACRITTY_EOF
success "~/.config/alacritty/alacritty.toml creado."

# ── 8. Verificar sesión Niri en GDM ──────────────────────────────────────────
header "8. Verificación de sesión GDM"
if [[ -f /usr/share/wayland-sessions/niri.desktop ]]; then
    success "niri.desktop encontrado en /usr/share/wayland-sessions/ — aparecerá en GDM."
else
    warn "No se encontró /usr/share/wayland-sessions/niri.desktop."
    warn "Puede que el paquete niri no haya instalado el fichero de sesión."
    warn "Comprueba con: rpm -ql niri | grep desktop"
fi

# ── Resumen final ─────────────────────────────────────────────────────────────
header "Instalación completada"
echo ""
echo -e "${GREEN}Todo listo. Pasos siguientes:${NC}"
echo ""
echo "  1. Reinicia el sistema (obligatorio si instalaste drivers Nvidia)."
if $IS_DESKTOP; then
    echo "     → En el sobremesa espera ~5 min tras el boot antes de entrar"
    echo "       para que akmod compile el módulo nvidia."
fi
echo ""
echo "  2. En GDM (pantalla de login), haz clic en el icono de engranaje"
echo "     y selecciona 'Niri' antes de introducir tu contraseña."
echo ""
echo "  3. Abre una terminal (Super+Enter) y ejecuta:"
echo "       niri msg outputs"
echo "     Copia el nombre exacto de tu monitor y edita:"
echo "       ~/.config/niri/config.kdl"
echo "     Reemplaza PLACEHOLDER por ese nombre."
echo ""
echo "  4. Niri recarga la config en caliente al guardar."
echo "     Puedes validarla sin estar en sesión con: niri validate"
echo ""
if $IS_DESKTOP; then
    echo -e "  ${YELLOW}Nvidia - workaround VRAM:${NC} revisa el uso con 'nvtop'."
    echo "  Debería estar en ~100 MiB. Si ves ~1 GiB, reinicia la sesión."
    echo ""
fi
echo "  Ficheros de config creados:"
echo "    ~/.config/niri/config.kdl"
echo "    ~/.config/waybar/config"
echo "    ~/.config/waybar/style.css"
echo "    ~/.config/mako/config"
echo "    ~/.config/fuzzel/fuzzel.ini"
echo "    ~/.config/alacritty/alacritty.toml"
echo ""
echo -e "${BLUE}¡Disfruta de Niri!${NC}"
