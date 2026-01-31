# Script de Configuración de Entorno de Desarrollo - ACTUALIZADO

Este script configura automáticamente Neovim (LazyVim) y Helix con todas las herramientas y configuraciones modernas.

## 🎯 Qué hace el script (ACTUALIZADO)

### 1. Instala paquetes del sistema (Fedora 43):
- Neovim (última versión estable)
- Helix
- .NET SDK 10
- Rust toolchain (rustc, cargo, rustfmt, clippy)
- Node.js y npm
- Python 3 y pip
- Build tools (gcc, g++, clang, cmake)
- Herramientas adicionales (git, ripgrep, fd-find)

### 2. Instala language servers y formateadores:
- **C#**: OmniSharp (compartido entre Neovim y Helix), Roslyn (solo Neovim), csharpier, netcoredbg
- **Rust**: rust-analyzer, rustfmt, clippy
- **C/C++**: clangd, clang-format
- **Python**: pyright, black
- **JavaScript/TypeScript**: typescript-language-server, prettier
- **YAML**: yaml-language-server
- **TOML**: taplo
- **JSON/HTML/CSS**: vscode-langservers-extracted
- **Markdown**: marksman

### 3. Configura Neovim (LazyVim):
- ✅ Añade "extras" de LazyVim para cada lenguaje
- ✅ **Diagnósticos mejorados** (ventanas flotantes automáticas al 0.5s)
- ✅ **Notificaciones más largas** (5 segundos en lugar de 2)
- ✅ **Trouble.nvim** para ver todos los errores
- ✅ **Roslyn LSP** para C# con convenciones modernas
- ✅ Formateo automático para cada lenguaje
- ✅ NO toca tu configuración de Helix

### 4. Configura Helix:
- ✅ **OmniSharp LSP** para C# (compartido con Neovim via Mason)
- ✅ **Symlink de OmniSharp** creado en ~/.local/bin
- ✅ Actualiza languages.toml para usar OmniSharp

### 5. Crea plantillas de configuración:
- ✅ **`.editorconfig.csharp-template`** - Reglas de C# 12+ modernas
- ✅ **`omnisharp.json.template`** - Configuración de OmniSharp para C# 12+

## 🚀 Uso

### Ejecutar el script:

```bash
chmod +x setup-dev-env.sh
./setup-dev-env.sh
```

El script pedirá contraseña de sudo para instalar paquetes del sistema.

### Primera vez después de ejecutar:

1. **Reinicia tu terminal** (para cargar variables de entorno)

2. **Abre Neovim:**
   ```bash
   nvim
   ```
   - Espera 2-3 minutos a que sincronice plugins
   - Verás el dashboard de LazyVim cuando termine

3. **Verifica instalación:**
   - `:Mason` - Ver herramientas instaladas
   - `:checkhealth` - Diagnóstico completo
   - `:Lazy` - Estado de plugins

4. **Para proyectos C#, copia las plantillas:**
   ```bash
   cd ~/tu-proyecto-csharp
   cp ~/.editorconfig.csharp-template .editorconfig
   cp ~/omnisharp.json.template omnisharp.json
   ```

## 📦 Características Configuradas

### Neovim (LazyVim)

#### Diagnósticos mejorados:
- Ventanas flotantes **aparecen automáticamente** al 0.5s
- Ver todos los errores: `Espacio + x + x`
- Navegar entre errores: `]e` / `[e`
- Ver error de línea: `gl` (inmediato)

#### Notificaciones:
- Duran **5 segundos** (antes 2s)
- Historial completo: `Espacio + u + N`
- Cerrar todas: `Espacio + u + n`

#### C# con Roslyn:
- LSP oficial de Microsoft
- Respeta `.editorconfig`
- Convenciones de C# 12+
- Refactoring avanzado

### Helix

#### C# con OmniSharp:
- Compartido con Neovim (via Mason)
- Respeta `.editorconfig` y `omnisharp.json`
- IntelliSense completo
- Code actions y refactoring

## 📚 Lenguajes Configurados

Los siguientes lenguajes quedarán completamente configurados con LSP, autocompletado, formateo y diagnósticos:

- ✅ **C#** (Roslyn en Neovim, OmniSharp en Helix)
- ✅ **Rust**
- ✅ **C/C++**
- ✅ **Python**
- ✅ **JavaScript/TypeScript/JSX/TSX**
- ✅ **YAML**
- ✅ **TOML**
- ✅ **JSON**
- ✅ **HTML**
- ✅ **CSS/SCSS**
- ✅ **Markdown**

## 🎨 Convenciones de C# 12+

Las plantillas `.editorconfig` y `omnisharp.json` configuran:

✅ **File-scoped namespaces**: `namespace Foo;` sin llaves
✅ **Preferir `var`**: Cuando el tipo es obvio
✅ **Braces opcionales**: Para statements de una línea
✅ **Expression-bodied members**: `public int Foo => _foo;`
✅ **Pattern matching moderno**: Switch expressions, not pattern
✅ **Características de C# 10+**: Index/range operators, implicit object creation

## 🔧 Archivos Creados/Modificados

### Neovim:
```
~/.config/nvim/
├── lua/
│   ├── config/
│   │   └── lazy.lua              (actualizado con language extras)
│   └── plugins/
│       ├── languages.lua         (nuevo)
│       ├── csharp-roslyn.lua     (mantiene tu config de Roslyn)
│       ├── diagnostics.lua       (nuevo)
│       └── notifications.lua     (nuevo)
```

### Helix:
```
~/.config/helix/
├── config.toml                   (configuración del editor)
└── languages.toml                (actualizado para usar OmniSharp)
```

### Plantillas:
```
~/
├── .editorconfig.csharp-template (plantilla para proyectos C#)
└── omnisharp.json.template       (plantilla para OmniSharp)
```

### Symlink:
```
~/.local/bin/omnisharp -> ~/.local/share/nvim/mason/packages/omnisharp/OmniSharp
```

## 🌐 Replicar en Otros Dispositivos

### Opción 1: Ejecutar el script
```bash
wget https://raw.githubusercontent.com/tu-usuario/tu-repo/main/setup-dev-env.sh
chmod +x setup-dev-env.sh
./setup-dev-env.sh
```

### Opción 2: Clonar tu configuración (recomendado)

**Primero, crea un repositorio git con tu configuración:**
```bash
cd ~/.config/nvim
git init
git add .
git commit -m "Initial Neovim config"
git remote add origin git@github.com:tu-usuario/nvim-config.git
git push -u origin main
```

**En otro dispositivo:**
```bash
# Ejecuta el script para instalar herramientas
./setup-dev-env.sh

# Clona tu configuración
rm -rf ~/.config/nvim
git clone git@github.com:tu-usuario/nvim-config.git ~/.config/nvim

# Abre Neovim y deja que sincronice
nvim
```

**Para Helix:**
```bash
cd ~/.config/helix
git init
git add .
git commit -m "Initial Helix config"
git remote add origin git@github.com:tu-usuario/helix-config.git
git push -u origin main
```

## 🐛 Solución de Problemas

### Language server no se conecta (Neovim)
```vim
:LspInfo          " Ver estado
:LspRestart       " Reiniciar
:Mason            " Verificar instalación
```

### OmniSharp no funciona en Helix
```bash
# Verificar symlink
ls -la ~/.local/bin/omnisharp

# Ver logs en Helix
# Abre Helix y escribe: :log-open

# Reinstalar OmniSharp
nvim
:Mason
# Buscar omnisharp y presionar 'i'
```

### Roslyn no funciona
- Verifica estar en directorio con `.csproj` o `.sln`
- Primera conexión tarda 1-2 minutos
- Verifica: `:LspInfo`

### Reinstalar Mason packages
```vim
:Mason
# En la ventana: presiona 'U' para actualizar todo
```

## 📊 Comparación: Antes vs Después

| Característica | Antes | Después |
|---------------|-------|---------|
| **Diagnósticos** | Línea única | Ventanas flotantes automáticas |
| **Notificaciones** | 2 segundos | 5 segundos + historial |
| **C# (Neovim)** | - | Roslyn (oficial) |
| **C# (Helix)** | csharp-ls | OmniSharp (compartido) |
| **Convenciones C#** | Antiguas | C# 12+ modernas |
| **Trouble.nvim** | ❌ No | ✅ Ver todos los errores |

## ⏱️ Tiempo Estimado

- **Primera ejecución**: 10-15 minutos (descarga e instalación)
- **Primera apertura de Neovim**: 2-3 minutos (sincronización de plugins)
- **Ejecuciones posteriores**: 5-10 minutos

## 📝 Notas Importantes

- ✅ El script es **idempotente**: puedes ejecutarlo múltiples veces
- ✅ **No toca tu configuración de Helix** si no es necesario
- ✅ Crea **backups** antes de modificar archivos existentes
- ✅ Neovim y Helix **comparten OmniSharp** (via Mason)
- ✅ Ambos respetan **el mismo `.editorconfig`**
- ✅ Si algo falla, revisa los mensajes de error

## 🎓 Guías Adicionales

Después de ejecutar el script, encontrarás estas guías en tu home:

- `DIAGNOSTICOS.md` - Guía de diagnósticos mejorados
- `NOTIFICACIONES.md` - Guía de notificaciones
- `HELIX-OMNISHARP.md` - Guía de OmniSharp en Helix
- `OMNISHARP-CONFIG.md` - Configuración de C# 12+

## ✨ Resultado Final

Después de ejecutar el script tendrás:

**Neovim:**
- 🚀 LazyVim completamente configurado
- 🔍 Diagnósticos con ventanas automáticas (0.5s)
- 📢 Notificaciones largas (5s) con historial
- 🎯 Roslyn LSP para C# 12+
- 🌈 Soporte para 11 lenguajes

**Helix:**
- 🎯 OmniSharp LSP para C# 12+
- 🔗 Compartido con Neovim (via Mason)
- ⚙️ Respeta .editorconfig

**Configuración compartida:**
- 📄 `.editorconfig` con convenciones de C# 12+
- 🛠️ `omnisharp.json` para sugerencias modernas
- 🔧 Todas las herramientas instaladas y listas

¡Todo listo para desarrollar con las mejores herramientas y configuraciones modernas!
