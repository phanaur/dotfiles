# Guía de instalación y configuración de Niri en Fedora

## Índice
1. [Instalación de paquetes](#1-instalación-de-paquetes)
2. [Configuración de Niri](#2-configuración-de-niri)
3. [Waybar (barra de estado)](#3-waybar-barra-de-estado)
4. [Mako (notificaciones)](#4-mako-notificaciones)
5. [Rofi-wayland (lanzador)](#5-rofi-wayland-lanzador)
6. [Arranque automático de servicios](#6-arranque-automático-de-servicios)
7. [Workaround Nvidia (sobremesa)](#7-workaround-nvidia-sobremesa)
8. [XWayland para apps legacy](#8-xwayland-para-apps-legacy)
9. [Referencia rápida de atajos](#9-referencia-rápida-de-atajos)

---

## 1. Instalación de paquetes

```bash
sudo dnf install niri waybar mako fuzzel \
  xwayland-satellite \
  gnome-keyring libsecret \
  polkit-gnome \
  swaybg \
  playerctl \
  brightnessctl \
  grim slurp \
  wl-clipboard \
  alacritty
```

### Verificar que Niri está disponible como sesión

Después de instalar, Niri debería aparecer como opción en GDM (el login de GNOME). Si no aparece, comprueba que existe el fichero de sesión:

```bash
ls /usr/share/wayland-sessions/niri.desktop
```

---

## 2. Configuración de Niri

El fichero de configuración principal es `~/.config/niri/config.kdl`. Niri usa el formato KDL, que es muy legible. Al arrancar Niri por primera vez se genera una configuración por defecto que puedes editar directamente.

```bash
mkdir -p ~/.config/niri
# Si quieres partir de la config por defecto generada por niri:
niri validate  # valida la config sin necesidad de estar en una sesión niri
```

### Configuración base recomendada

```kdl
// ~/.config/niri/config.kdl

// --- Input ---
input {
    keyboard {
        xkb {
            layout "es"
            // Si usas variante: variant "deadtilde"
        }
    }
    touchpad {
        tap
        natural-scroll
        accel-speed 0.2
    }
    // El foco sigue al ratón
    focus-follows-mouse
}

// --- Outputs (pantallas) ---
// Sobremesa: ajusta el nombre con `niri msg outputs`
output "DP-1" {
    mode "1920x1080@60.000"
    scale 1.0
    position x=0 y=0
}

// Portátil: pantalla interna
// output "eDP-1" {
//     mode "1920x1080@60.000"
//     scale 1.0
// }

// --- Layout ---
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
        active-color "#89b4fa"   // azul suave (puedes cambiar el color)
        inactive-color "#45475a"
    }

    border {
        off
    }
}

// --- Animaciones ---
animations {
    // Puedes ajustar la velocidad. slowdown 1.0 es normal, 0.5 es más rápido.
    slowdown 0.8
}

// --- Arranque de aplicaciones y servicios ---
spawn-at-startup "waybar"
spawn-at-startup "mako"
spawn-at-startup "swaybg" "-m" "fill" "-i" "/ruta/a/tu/wallpaper.jpg"
spawn-at-startup "/usr/libexec/polkit-gnome-authentication-agent-1"
spawn-at-startup "xwayland-satellite"
// gnome-keyring se lanza automáticamente por PAM en Fedora, no hace falta aquí

// --- Reglas de ventanas ---
// Ventanas flotantes por defecto para ciertas apps
window-rule {
    match app-id="org.gnome.Calculator"
    match app-id="pavucontrol"
    open-floating true
}

// --- Atajos de teclado ---
binds {
    // Super = tecla Windows/Meta
    Mod+Return { spawn "alacritty"; }      // terminal
    Mod+D { spawn "fuzzel"; }              // lanzador
    Mod+Shift+Q { close-window; }
    Mod+Shift+E { quit; }

    // Navegación entre ventanas (foco)
    Mod+H { focus-column-left; }
    Mod+L { focus-column-right; }
    Mod+J { focus-window-down; }
    Mod+K { focus-window-up; }

    // Mover ventanas
    Mod+Shift+H { move-column-left; }
    Mod+Shift+L { move-column-right; }
    Mod+Shift+J { move-window-down; }
    Mod+Shift+K { move-window-up; }

    // Cambiar tamaño de columna
    Mod+R { switch-preset-column-width; }
    Mod+F { maximize-column; }
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

    // Scroll entre columnas con rueda del ratón sobre la barra
    Mod+WheelScrollRight { focus-column-right; }
    Mod+WheelScrollLeft  { focus-column-left; }

    // Captura de pantalla
    Print { screenshot; }
    Mod+Print { screenshot-window; }

    // Control de volumen
    XF86AudioRaiseVolume  { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"; }
    XF86AudioLowerVolume  { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
    XF86AudioMute         { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }

    // Brillo (portátil)
    XF86MonBrightnessUp   { spawn "brightnessctl" "set" "10%+"; }
    XF86MonBrightnessDown { spawn "brightnessctl" "set" "10%-"; }
}
```

> **Importante:** Ejecuta `niri msg outputs` dentro de una sesión Niri para ver los nombres exactos de tus pantallas y ajusta la sección `output` del config.

---

## 3. Waybar (barra de estado)

```bash
mkdir -p ~/.config/waybar
```

### `~/.config/waybar/config`

```json
{
    "layer": "top",
    "position": "top",
    "height": 30,
    "spacing": 4,

    "modules-left": ["niri/workspaces", "niri/window"],
    "modules-center": ["clock"],
    "modules-right": ["pulseaudio", "network", "battery", "tray", "custom/power"],

    "niri/workspaces": {
        "format": "{name}"
    },
    "niri/window": {
        "max-length": 50
    },
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
    "tray": {
        "spacing": 8
    },
    "custom/power": {
        "format": "⏻",
        "on-click": "niri msg action quit"
    }
}
```

### `~/.config/waybar/style.css`

```css
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
```

---

## 4. Mako (notificaciones)

```bash
mkdir -p ~/.config/mako
```

### `~/.config/mako/config`

```ini
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
```

---

## 5. Fuzzel (lanzador)

Fuzzel es nativo Wayland, muy ligero y sin dependencias pesadas. Se configura en `~/.config/fuzzel/fuzzel.ini`.

```bash
mkdir -p ~/.config/fuzzel
```

### `~/.config/fuzzel/fuzzel.ini`

```ini
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
# Modo dmenu para scripts
exit-immediately-if-empty=no
```

Se lanza simplemente con `fuzzel`. Para usarlo como selector de ficheros u otros modos, acepta entrada por stdin igual que dmenu.

---

## 6. Arranque automático de servicios

En Niri los servicios se lanzan con `spawn-at-startup` en el config.kdl (ya incluido arriba). Adicionalmente, para gnome-keyring en Fedora es suficiente con que el PAM lo gestione, lo cual ocurre automáticamente en GDM.

Si en algún momento ves que las aplicaciones no encuentran el keyring, puedes añadir esto a `~/.bash_profile` o `~/.zprofile`:

```bash
if [ -z "$GNOME_KEYRING_CONTROL" ]; then
    eval $(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
    export GNOME_KEYRING_CONTROL GNOME_KEYRING_PID GPG_AGENT_INFO SSH_AUTH_SOCK
fi
```

---

## 7. Workaround Nvidia (sobremesa)

Este paso **solo aplica al sobremesa** con la GTX 1080. Soluciona el problema de VRAM que no se libera correctamente.

```bash
# Crear el directorio si no existe
sudo mkdir -p /etc/nvidia/nvidia-application-profiles-rc.d

# Crear el fichero de perfil
sudo tee /etc/nvidia/nvidia-application-profiles-rc.d/50-niri-vram.json > /dev/null << 'EOF'
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
EOF
```

Reinicia la sesión de Niri para que surta efecto. Puedes verificar el uso de VRAM con `nvtop`: debería mantenerse alrededor de 100 MiB en reposo, no cerca del GiB.

### DRM kernel mode setting (necesario para Nvidia + Wayland)

Asegúrate de que el KMS de Nvidia está activado. En Fedora con los drivers propietarios:

```bash
# Comprobar si ya está activo
cat /proc/driver/nvidia/params | grep EnableGpuFirmware

# Añadir el parámetro al kernel si no está
sudo grubby --update-kernel=ALL --args="nvidia-drm.modeset=1"
sudo reboot
```

---

## 8. XWayland para apps legacy

`xwayland-satellite` permite ejecutar aplicaciones X11 en Niri sin necesidad de soporte XWayland nativo. Ya está incluido en el `spawn-at-startup` de la config.

```bash
# Verificar que está corriendo
pgrep xwayland-satellite

# Si alguna app X11 no arranca correctamente, forzar DISPLAY:
DISPLAY=:0 nombre-de-app
```

Las aplicaciones que más frecuentemente necesitan esto: algunas versiones de Java (IDEs como IntelliJ si no tienen modo Wayland), algunas apps GTK2 antiguas, y herramientas gráficas X11 sin puerto a Wayland.

---

## 9. Referencia rápida de atajos

| Atajo | Acción |
|-------|--------|
| `Super + Enter` | Terminal (foot) |
| `Super + D` | Lanzador (rofi) |
| `Super + Shift + Q` | Cerrar ventana |
| `Super + H/L` | Mover foco izq/dcha |
| `Super + J/K` | Mover foco arriba/abajo |
| `Super + Shift + H/L` | Mover columna izq/dcha |
| `Super + R` | Cambiar preset de ancho |
| `Super + F` | Maximizar columna |
| `Super + Shift + F` | Pantalla completa |
| `Super + 1-5` | Ir al workspace N |
| `Super + Shift + 1-5` | Mover ventana al workspace N |
| `Print` | Captura de pantalla |
| `Super + Shift + E` | Salir de Niri |

---

## Primeros pasos tras instalar

1. Instala los paquetes del paso 1.
2. Crea los ficheros de configuración (niri, waybar, mako).
3. En el sobremesa, aplica el workaround de Nvidia y activa el KMS.
4. Selecciona "Niri" en el menú de GDM al hacer login.
5. Dentro de la sesión, ejecuta `niri msg outputs` para ver el nombre exacto de tu monitor y ajusta el bloque `output` en el config.
6. Edita y guarda el config: Niri recarga la configuración en caliente automáticamente, sin necesidad de reiniciar.

> **Tip:** Si cometes un error en el config y Niri no lo acepta, te notificará y mantendrá la última configuración válida. Puedes validar el config desde terminal con `niri validate` antes de guardarlo.
