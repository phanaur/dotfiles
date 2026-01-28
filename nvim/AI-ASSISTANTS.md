# Asistentes de IA en Neovim

Configuración completa de **Claude Code** y **Google Gemini** integrados en Neovim.

## 📦 Plugins Instalados

### 1. Claude Code (`coder/claudecode.nvim`)
- Integración oficial de Claude Code con Neovim
- Protocolo WebSocket MCP compatible
- Terminal split integrado
- Diff viewer para revisar cambios

### 2. Google Gemini CLI (`marcinjahn/gemini-cli.nvim`)
- Integración con Gemini CLI
- Análisis de diagnósticos
- Sintaxis @ para referencias a archivos
- Terminal interactivo

## 🚀 Instalación de Dependencias

### Claude Code CLI

**Instalación automática:**
Si usaste los scripts de instalación de dotfiles (`setup-dev-env.sh` o `install.sh`), Claude Code CLI ya está instalado.

**Instalación manual (si es necesario):**

```bash
# Script oficial de instalación (RECOMENDADO)
curl -fsSL https://claude.ai/install.sh | bash
```

**Nota:** La instalación vía npm (`npm install -g @anthropic-ai/claude-code`) ya no está soportada. Usa el script oficial.

**Autenticación (REQUERIDO):**
```bash
# Esto es lo único que necesitas hacer después de la instalación
claude login
```

**Verificación:**
```bash
which claude
claude --version
```

### Google Gemini CLI

**Instalación:**
```bash
pip install google-generativeai
pip install gemini-cli
```

**Configurar API Key:**
```bash
# Obtener API Key en: https://makersuite.google.com/app/apikey
export GOOGLE_API_KEY="tu-api-key-aqui"
```

**Permanente (añadir a ~/.bashrc o ~/.zshrc):**
```bash
echo 'export GOOGLE_API_KEY="tu-api-key-aqui"' >> ~/.bashrc
source ~/.bashrc
```

## ⌨️ Keybindings

### Claude Code (`<leader>c`)

| Atajo | Modo | Descripción |
|-------|------|-------------|
| `<leader>cc` | Normal | Toggle terminal de Claude |
| `<leader>cf` | Normal | Focus en Claude |
| `<leader>cr` | Normal | Resume última sesión |
| `<leader>cC` | Normal | Continue conversación |
| `<leader>cm` | Normal | Seleccionar modelo |
| `<leader>cb` | Normal | Añadir buffer actual al contexto |
| `<leader>cs` | Visual | Enviar selección a Claude |

### Google Gemini (`<leader>m`)

**NOTA:** Keybindings cambiados de `<leader>g` a `<leader>m` para evitar conflicto con Git.

| Atajo | Modo | Descripción |
|-------|------|-------------|
| `<leader>mm` | Normal | Toggle terminal de Gemini |
| `<leader>ma` | Normal/Visual | Ask Gemini |
| `<leader>mf` | Normal | Añadir archivo actual |
| `<leader>md` | Normal | Enviar diagnósticos |
| `<leader>mh` | Normal | Health check |
| `<leader>mx` | Normal | Fix errores automático |

## 📖 Workflows Comunes

### Claude Code - Workflow básico

```vim
1. Abrir Claude:           <leader>cc
2. Añadir contexto:        <leader>cb  (o <leader>cs en visual)
3. Escribir prompt:        (en el terminal de Claude)
4. Revisar cambios:        :ClaudeCodeDiffAccept
                          :ClaudeCodeDiffDeny
5. Focus de vuelta:        <leader>cf
```

**Ejemplo práctico:**
1. Abre un archivo con bug
2. Selecciona el código problemático (visual mode)
3. `<leader>cs` para enviar a Claude
4. Escribe en el terminal: "Fix this null reference error"
5. Revisa el diff y acepta con `:ClaudeCodeDiffAccept`

### Gemini CLI - Workflow básico

```vim
1. Abrir Gemini:           <leader>mm
2. Añadir archivo:         <leader>mf
3. Preguntar:              <leader>ma
4. Ver errores:            <leader>md
5. Fix automático:         <leader>mx
```

**Ejemplo práctico:**
1. Abre un archivo con errores
2. `<leader>mx` para enviar diagnósticos y pedir soluciones
3. Gemini analizará todos los errores del archivo
4. Te dará soluciones específicas para cada uno

### Uso combinado

```vim
# Usa Claude para implementaciones complejas
<leader>cc → "Implement user authentication with JWT"

# Usa Gemini para análisis de errores
<leader>mx → Analiza y fix automático de errores

# Usa Claude para refactoring
<leader>cs (visual) → "Refactor this to use async/await"

# Usa Gemini para explicaciones
<leader>ma → "Explain this algorithm"
```

## 🎯 Comandos Útiles

### Claude Code

```vim
:ClaudeCode              " Toggle terminal
:ClaudeCodeFocus         " Focus/toggle con comportamiento inteligente
:ClaudeCodeSend          " Enviar selección visual
:ClaudeCodeAdd {file}    " Añadir archivo al contexto
:ClaudeCodeDiffAccept    " Aceptar cambios propuestos
:ClaudeCodeDiffDeny      " Rechazar cambios propuestos
:ClaudeHelp              " Mostrar ayuda rápida
```

### Gemini CLI

```vim
:Gemini                      " Menú interactivo
:Gemini toggle               " Toggle terminal
:Gemini ask                  " Preguntar a Gemini
:Gemini add_file             " Añadir archivo actual
:Gemini add_diagnostics      " Añadir diagnósticos
:Gemini health               " Verificar estado
:Gemini send "tu pregunta"   " Enviar mensaje directo
:GeminiFixErrors             " Fix automático de errores
:GeminiHelp                  " Mostrar ayuda rápida
```

## ⚙️ Configuración Avanzada

### Cambiar posición del terminal

**Claude Code** (en `lua/plugins/ai-claude.lua`):
```lua
terminal = {
  split_side = "right",  -- left, right
  split_width_percentage = 0.35,  -- 35% del ancho
}
```

**Gemini** (en `lua/plugins/ai-gemini.lua`):
```lua
win = {
  position = "right",  -- right, left, bottom, top
}
```

### Usar ventana flotante (Claude)

```lua
terminal = {
  snacks_win_opts = {
    position = "float",
    width = 0.9,    -- 90% del ancho
    height = 0.9,   -- 90% de la altura
  },
}
```

### Cambiar nivel de logs (Claude)

```lua
opts = {
  log_level = "debug",  -- trace, debug, info, warn, error
}
```

## 🐛 Solución de Problemas

### Claude Code

**Error: "claude command not found"**
```bash
# Verificar instalación
which claude

# Reinstalar
npm install -g claude-cli
# o
curl -fsSL https://claude.ai/install.sh | sh
```

**Error: "Not authenticated"**
```bash
claude login
```

**Terminal no se abre:**
- Verificar que `snacks.nvim` está instalado
- Revisar `:checkhealth claudecode`

### Gemini CLI

**Error: "gemini command not found"**
```bash
# Verificar instalación
which gemini

# Reinstalar
pip install --upgrade gemini-cli
```

**Error: "API key not found"**
```bash
# Configurar API key
export GOOGLE_API_KEY="tu-api-key"

# Verificar
echo $GOOGLE_API_KEY
```

**Terminal no responde:**
```bash
# Verificar que el CLI funciona
gemini "Hello"

# Verificar versión de Python
python --version  # Debe ser 3.8+
```

## 📊 Comparación: Claude vs Gemini

| Característica | Claude Code | Gemini CLI |
|----------------|-------------|------------|
| **Gratis** | ❌ Requiere suscripción | ✅ API gratuita disponible |
| **Calidad** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Velocidad** | 🚀 Rápido | 🚀🚀 Muy rápido |
| **Contexto** | 200k tokens | 100k tokens |
| **Mejor para** | Implementaciones complejas | Análisis rápidos, fix de bugs |
| **Diff viewer** | ✅ Integrado | ❌ No |
| **Diagnósticos** | Manual | ✅ Automático |

## 💡 Tips y Trucos

### 1. Contexto selectivo
```vim
" Solo envía el código relevante, no todo el archivo
" Selecciona solo la función/clase que necesitas
```

### 2. Prompts efectivos
```
❌ "Fix this"
✅ "Fix the null reference exception in line 42 by adding null check"

❌ "Make it better"
✅ "Refactor this function to use dependency injection pattern"
```

### 3. Usa ambos asistentes
```vim
" Claude para features nuevas
<leader>cc → "Add user registration endpoint with validation"

" Gemini para debugging rápido
<leader>mx → Analiza todos los errores
```

### 4. Workflow de refactoring
```vim
1. <leader>cs (selecciona código)
2. "Identify code smells and suggest improvements"
3. Revisa sugerencias
4. "Implement the observer pattern you suggested"
5. :ClaudeCodeDiffAccept
```

## 📚 Recursos

- [Claude Code Docs](https://docs.anthropic.com/claude/docs/claude-code)
- [Gemini API Docs](https://ai.google.dev/docs)
- [API Keys Gemini](https://makersuite.google.com/app/apikey)

## 🔄 Sincronización e Instalación

### Instalación automática de Claude Code

Los scripts de instalación de dotfiles ya incluyen Claude Code CLI:

**`setup-dev-env.sh`** (instalación completa):
- Instala automáticamente Claude Code CLI vía npm
- Solo necesitas ejecutar `claude login` después

**`install.sh`** (instalación de dotfiles):
- Pregunta si quieres instalar Claude Code CLI
- Si aceptas, lo instala automáticamente
- Solo necesitas ejecutar `claude login` después

### Archivos sincronizados

Estos archivos ya están incluidos en tu dotfiles y se sincronizan automáticamente:
- `~/.config/nvim/lua/plugins/ai-claude.lua`
- `~/.config/nvim/lua/plugins/ai-gemini.lua`
- `~/.config/nvim/AI-ASSISTANTS.md`
- Scripts de instalación (`setup-dev-env.sh`, `install.sh`)

## ✨ Próximos Pasos

### Si acabas de instalar dotfiles:

1. **Autenticar Claude Code (ÚNICO PASO NECESARIO):**
   ```bash
   claude login
   ```

2. **Opcional - Instalar Gemini CLI:**
   ```bash
   pip install gemini-cli
   export GOOGLE_API_KEY="tu-key"
   ```

3. **Probar en Neovim:**
   ```vim
   :ClaudeHelp
   :GeminiHelp  # Si instalaste Gemini
   ```

4. **Workflow básico:**
   - `<leader>cc` para Claude
   - `<leader>mm` para Gemini (opcional)
   - ¡Empieza a programar con IA!

### En nuevos dispositivos:

1. Clonar dotfiles: `git clone git@github.com:tu-usuario/dotfiles.git ~/github/dotfiles`
2. Ejecutar instalación: `bash ~/github/dotfiles/install.sh`
3. Autenticar: `claude login`
4. ¡Listo! Claude Code ya funciona en Neovim

---

**Notas:**
- Claude Code CLI se instala automáticamente con los scripts de dotfiles
- Solo necesitas autenticarte una vez con `claude login`
- Ambos plugins se cargan de forma lazy (solo cuando se usan)
- No afectan el tiempo de inicio de Neovim
