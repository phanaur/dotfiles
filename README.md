# Dotfiles - Configuración de Desarrollo

Configuración completa de Neovim (LazyVim) y Helix para desarrollo en C#, Go, Rust, Python, TypeScript y más.

## 🐧 Distribuciones Soportadas

Los scripts de instalación son compatibles con las principales distribuciones Linux:

- ✅ **Ubuntu / Debian / Linux Mint / Pop!_OS** (apt)
- ✅ **Fedora** (dnf)
- ✅ **Arch Linux / Manjaro / EndeavourOS** (pacman)
- ✅ **openSUSE / SLES** (zypper)

El script detecta automáticamente tu distribución y usa el gestor de paquetes apropiado.

## 📦 Contenido del Repositorio

### Estructura Recomendada:

```
dotfiles/
├── nvim/                           # Configuración de Neovim
│   ├── lua/
│   │   ├── config/
│   │   │   ├── lazy.lua           ← SINCRONIZAR
│   │   │   ├── options.lua        ← SINCRONIZAR
│   │   │   └── keymaps.lua        ← SINCRONIZAR
│   │   └── plugins/
│   │       ├── languages.lua      ← SINCRONIZAR
│   │       ├── csharp-roslyn.lua  ← SINCRONIZAR
│   │       ├── go.lua              ← SINCRONIZAR
│   │       ├── autosave.lua       ← SINCRONIZAR
│   │       ├── diagnostics.lua    ← SINCRONIZAR
│   │       └── notifications.lua  ← SINCRONIZAR
│   └── init.lua                   ← SINCRONIZAR
│
├── helix/                          # Configuración de Helix
│   ├── config.toml                ← SINCRONIZAR
│   ├── languages.toml             ← SINCRONIZAR
│   └── themes/                    ← SINCRONIZAR (si tienes temas personalizados)
│       └── synthwave84.toml
│
├── templates/                      # Plantillas para proyectos
│   ├── .editorconfig.csharp       ← SINCRONIZAR
│   └── omnisharp.json             ← SINCRONIZAR
│
├── scripts/                        # Scripts de instalación
│   └── setup-dev-env.sh           ← SINCRONIZAR
│
├── docs/                           # Documentación
│   ├── DIAGNOSTICOS.md            ← SINCRONIZAR
│   ├── NOTIFICACIONES.md          ← SINCRONIZAR
│   ├── AUTOGUARDADO.md            ← SINCRONIZAR
│   ├── HELIX-AUTOSAVE.md          ← SINCRONIZAR
│   ├── HELIX-OMNISHARP.md         ← SINCRONIZAR
│   ├── OMNISHARP-CONFIG.md        ← SINCRONIZAR
│   └── GUIA-CSHARP.md             ← SINCRONIZAR
│
├── .gitignore                      ← SINCRONIZAR
├── README.md                       ← SINCRONIZAR
└── install.sh                      ← SINCRONIZAR (crear)
```

## ❌ NO Sincronizar

### Helix:
- ❌ `runtime/` - **1.8GB** de grammars compilados (se generan automáticamente)

### Neovim:
- ❌ `lazy-lock.json` - Lock file de plugins (se genera automáticamente)
- ❌ `.luarc.json` - Configuración de LSP Lua local
- ❌ Archivos de backup (`*.backup`, `*.swp`, etc.)

Estos archivos están en `.gitignore` y no se sincronizarán.

## 🚀 Instalación en Nuevo Dispositivo

### Opción 1: Con Script Automatizado (Recomendado)

```bash
# Clonar el repositorio
git clone git@github.com:tu-usuario/dotfiles.git ~/dotfiles

# Ejecutar script de instalación
cd ~/dotfiles
./install.sh
```

### Opción 2: Manual

```bash
# Clonar el repositorio
git clone git@github.com:tu-usuario/dotfiles.git ~/dotfiles

# Instalar dependencias del sistema
./scripts/setup-dev-env.sh

# Crear enlaces simbólicos
ln -sf ~/dotfiles/nvim ~/.config/nvim
ln -sf ~/dotfiles/helix ~/.config/helix

# Instalar grammars de Helix (IMPORTANTE)
hx --grammar fetch
hx --grammar build

# Abrir Neovim para instalar plugins
nvim
# Espera a que Lazy sincronice plugins
# Luego :Mason para verificar herramientas
```

## 📋 Checklist Post-Instalación

- [ ] **Helix**: Ejecutar `hx --grammar fetch && hx --grammar build`
- [ ] **Neovim**: Abrir `nvim` y esperar a que Lazy sincronice
- [ ] **Mason**: Verificar herramientas con `:Mason`
- [ ] **OmniSharp**: Verificar symlink con `ls -la ~/.local/bin/omnisharp`
- [ ] **Claude Code**: Autenticar con `claude login`
- [ ] **Neovim AI**: Verificar con `:ClaudeHelp`
- [ ] **Proyectos C#**: Copiar templates (`.editorconfig`, `omnisharp.json`)

## 🔧 Configuración Incluida

### Neovim (LazyVim):
- ✅ **Auto-save** (1 segundo)
- ✅ **Roslyn LSP** para C# 12+
- ✅ **Diagnósticos automáticos** (ventanas flotantes al 0.5s)
- ✅ **Notificaciones largas** (5 segundos + historial)
- ✅ **Soporte multi-lenguaje** (11 lenguajes)
- ✅ **Trouble.nvim** para ver todos los errores
- ✅ **Claude Code CLI** integrado

### AI Assistants:
- ✅ **Claude Code CLI** integrado en Neovim
- ✅ Keybindings: `<leader>cc`, `<leader>cb`, `<leader>cs`, `<leader>cf`, `<leader>cm`, `<leader>cr`
- ✅ Diff viewer para revisar cambios
- ✅ Terminal split integrado

### Helix:
- ✅ **Auto-save** (1 segundo)
- ✅ **OmniSharp LSP** para C# 12+
- ✅ **Tema personalizado** (synthwave84)
- ✅ **Inlay hints** activados
- ✅ **Diagnósticos inline**

### Compartido:
- ✅ **Mismas convenciones de C#** (.editorconfig)
- ✅ **OmniSharp compartido** (via Mason)
- ✅ **Todas las herramientas** instaladas

## 🌐 Sincronización

### Subir cambios:

```bash
cd ~/dotfiles
git add .
git commit -m "Update config"
git push
```

### Actualizar en otro dispositivo:

```bash
cd ~/dotfiles
git pull

# Si cambiaste plugins de Neovim
nvim
:Lazy sync

# Si cambiaste language servers de Helix
hx --grammar fetch
hx --grammar build
```

## 📝 Notas Importantes

1. **Runtime de Helix**: Se genera automáticamente, no sincronizar (1.8GB)
2. **Lazy-lock de Neovim**: Se genera automáticamente
3. **OmniSharp**: Se instala via Mason en Neovim, Helix usa symlink
4. **Themes de Helix**: Si añades/modificas temas, sincronízalos
5. **EditorConfig**: Copia templates a proyectos C# según necesites

## 🐛 Solución de Problemas

### Helix no encuentra grammars
```bash
hx --grammar fetch
hx --grammar build
```

### Neovim no carga plugins
```bash
nvim
:Lazy sync
```

### OmniSharp no funciona en Helix
```bash
# Verificar symlink
ls -la ~/.local/bin/omnisharp

# Reinstalar
nvim
:Mason
# Buscar omnisharp y reinstalar
```

## 📚 Documentación

Toda la documentación está en la carpeta `docs/`:
- Diagnósticos mejorados
- Notificaciones
- Auto-save (Neovim y Helix)
- Configuración de C# 12+
- Y más...

## 🎯 Lo que Sincronizas

**Archivos de configuración:**
- Neovim: `~/.config/nvim/` (sin lazy-lock.json)
- Helix: `~/.config/helix/` (sin runtime/)

**Scripts y documentación:**
- Script de instalación
- Plantillas para proyectos
- Guías completas

**Total aproximado: ~500KB** (sin runtime de Helix)

## ✨ Resultado

Después de clonar e instalar, tendrás exactamente la misma configuración en cualquier dispositivo:
- Mismos editores configurados
- Mismas herramientas instaladas
- Mismas convenciones de código
- Mismos atajos de teclado

¡Todo listo para programar inmediatamente!
