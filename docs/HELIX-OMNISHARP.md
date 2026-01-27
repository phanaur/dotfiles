# Helix + OmniSharp Configuración Completada

## ✅ Instalación Completada

- **OmniSharp instalado** via Mason (Neovim)
- **Symlink creado** en `~/.local/bin/omnisharp`
- **Helix configurado** para usar OmniSharp
- **Detectado** .NET SDK 10.0.102

## Cómo Probar

### 1. Abre un proyecto C# con Helix:

```bash
cd ~/github/n-bodies-sim
hx Calculator.cs
```

### 2. Espera a que OmniSharp se conecte

La primera vez puede tardar 10-20 segundos en:
- Analizar el proyecto
- Cargar dependencias
- Indexar el código

Verás mensajes en la parte inferior cuando esté listo.

### 3. Prueba las funcionalidades:

**IntelliSense (autocompletado):**
- Empieza a escribir código
- El autocompletado aparecerá automáticamente

**Ir a definición:**
- Pon el cursor sobre un símbolo
- Presiona `gd`

**Ver referencias:**
- Presiona `gr`

**Renombrar símbolo:**
- Presiona `Space` + `r` (o el atajo que tengas configurado)

**Code actions (refactoring):**
- Presiona `Space` + `a`

## Ventajas de OmniSharp

✅ **Respeta `.editorconfig`** - Usará las mismas convenciones que configuraste
✅ **IntelliSense completo** - Autocompletado inteligente
✅ **Refactoring** - Renombrar, extraer métodos, etc.
✅ **Diagnósticos** - Errores y warnings en tiempo real
✅ **Ir a definición** - Navega fácilmente por el código
✅ **Compatible con .NET 10** - Funciona perfectamente

## Compartido entre Neovim y Helix

Ahora tanto Neovim como Helix usan:
- **El mismo OmniSharp** (instalado via Mason)
- **El mismo `.editorconfig`** en tus proyectos
- **Las mismas herramientas** (csharpier para formateo)

## Troubleshooting

### OmniSharp no se conecta en Helix

1. Verifica que estés en un directorio con `.csproj` o `.sln`
2. Abre Helix con `:log-open` para ver logs del LSP
3. Verifica el symlink: `ls -la ~/.local/bin/omnisharp`

### OmniSharp tarda mucho en iniciar

- Es normal la primera vez (10-20 segundos)
- Proyectos grandes pueden tardar más
- Una vez conectado, será rápido en aperturas posteriores

### Quiero volver a csharp-ls

Edita `~/.config/helix/languages.toml` y cambia:
```toml
language-servers = ["csharp-ls"]

[language-server.csharp-ls]
command = "csharp-ls"
```

## Actualizar OmniSharp

Para actualizar OmniSharp en el futuro:

1. Abre Neovim: `nvim`
2. Ejecuta: `:Mason`
3. Busca `omnisharp`
4. Presiona `U` para actualizar
5. El symlink se actualizará automáticamente

## Estado de la Configuración

```
Neovim:
  - Roslyn LSP (oficial de Microsoft) ✅
  - Respeta .editorconfig ✅
  - Todas las funcionalidades modernas ✅

Helix:
  - OmniSharp LSP ✅
  - Respeta .editorconfig ✅
  - IntelliSense + Refactoring ✅
  - Compartido con Neovim vía Mason ✅
```

¡Ahora tienes una configuración completa y consistente entre Neovim y Helix!
