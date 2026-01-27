# Guía Rápida: LazyVim para C# / .NET 10

## Instalación Completa

LazyVim se instalará automáticamente la primera vez que abras Neovim. Sigue estos pasos:

### 1. Primera ejecución
```bash
nvim
```

Verás una pantalla con plugins instalándose. **Espera a que termine completamente** (puede tardar 2-3 minutos).

### 2. Instalar herramientas de C#

Una vez cargado, presiona `:` para entrar en modo comando y escribe:
```
:LazyExtras
```

Presiona Enter. Verás una lista de "extras". Busca `lang.dotnet` y presiona `x` sobre él para habilitarlo.

Luego presiona `q` para salir.

### 3. Instalar Roslyn LSP (se hace automáticamente)

El language server oficial de Microsoft (Roslyn) se instalará automáticamente.

Si quieres instalarlo manualmente, escribe:
```
:Mason
```

Presiona Enter. En la ventana que se abre:
- Escribe `/roslyn` para buscarlo
- Presiona Enter
- Presiona `i` para instalarlo
- Espera a que termine la instalación (puede tardar varios minutos)
- Presiona `q` para salir

También se instalarán automáticamente:
- `csharpier` (formateador de código)
- `netcoredbg` (debugger)

### 4. Probar con un proyecto

```bash
cd /tmp/test-nvim-csharp
nvim Program.cs
```

Espera unos segundos a que Roslyn se conecte (verás un mensaje en la parte inferior).

**IMPORTANTE**: La primera vez que se conecte Roslyn puede tardar 1-2 minutos en analizar el proyecto completo.

## Atajos de Teclado Principales

**NOTA**: La tecla "líder" es `Espacio` (la barra espaciadora)

### Navegación de Código
- `gd` - Ir a definición (con Telescope si está disponible)
- `gr` - Ver referencias
- `gi` - Ir a implementación
- `K` - Mostrar documentación (hover)
- `<leader>ca` - **Code Actions** (refactorings y quick fixes)

### Refactoring
- `<leader>cr` - Renombrar símbolo
- `<leader>ca` - Code actions (aquí encuentras: extract method, inline variable, etc.)
- `<leader>cf` - Formatear archivo

### Búsqueda (Telescope)
- `<leader>ff` - Buscar archivos
- `<leader>fg` - Buscar texto en archivos
- `<leader>fs` - Buscar símbolos en archivo actual
- `<leader><space>` - Buscar buffers

### Explorador de Archivos
- `<leader>e` - Abrir/cerrar explorador (neo-tree)

### Diagnósticos (Errores/Warnings)
- `]d` - Siguiente diagnóstico
- `[d` - Diagnóstico anterior
- `<leader>cd` - Ver diagnósticos en lista

### Terminal Integrado
- `<leader>ft` - Terminal flotante
- `<leader>fT` - Terminal en pestaña

### Git
- `<leader>gg` - Abrir Lazygit (si está instalado)
- `]h` - Siguiente cambio
- `[h` - Cambio anterior
- `<leader>gp` - Preview del cambio

## Refactorings Disponibles

Cuando estés sobre un símbolo y presiones `<leader>ca`, verás opciones como:

1. **Extract method** - Extraer código a un método
2. **Inline variable/method** - Hacer inline
3. **Generate constructor** - Generar constructor
4. **Add using statement** - Agregar using
5. **Convert to block body/expression body**
6. **Generate equals and GetHashCode**
7. Y muchos más...

## Debugging (Opcional)

Si instalaste `netcoredbg`:
- `<leader>db` - Toggle breakpoint
- `<leader>dc` - Continue
- `<leader>di` - Step into
- `<leader>do` - Step over

## Comandos Útiles

- `:Lazy` - Ver estado de plugins
- `:Mason` - Instalar/actualizar herramientas
- `:LazyExtras` - Habilitar/deshabilitar extras
- `:checkhealth` - Verificar problemas

## Formato de Código Automático

Si instalaste `csharpier`, el código se formateará automáticamente al guardar.

Para deshabilitarlo:
```
:lua vim.b.autoformat = false
```

## Próximos Pasos

1. Explora los atajos con `<leader>` (Espacio) - aparecerá un menú con todas las opciones
2. Lee `:help LazyVim` para más información
3. Personaliza en `~/.config/nvim/lua/plugins/`

## Configuración de EditorConfig

He creado un archivo `.editorconfig` en tu proyecto de prueba con las convenciones modernas de C# 12+:

- ✅ File-scoped namespaces (namespace Foo;)
- ✅ Preferir `var` cuando el tipo es obvio
- ✅ Braces opcionales en statements de una línea
- ✅ Expression-bodied members
- ✅ Pattern matching moderno
- ✅ Y muchas más...

Copia este archivo a la raíz de tus proyectos C# para tener las mismas convenciones:
```bash
cp /tmp/test-nvim-csharp/.editorconfig ~/tu-proyecto/
```

## Problemas Comunes

### Roslyn no se conecta
- Verifica que estés en un directorio con un archivo `.csproj` o `.sln`
- La primera conexión puede tardar 1-2 minutos
- Ejecuta `:LspInfo` para ver el estado
- Ejecuta `:LspRestart` para reiniciarlo

### Completado no funciona
- Espera unos segundos después de abrir el archivo
- Verifica con `:LspInfo` que OmniSharp esté conectado

### No veo code actions
- Asegúrate de estar sobre un símbolo (variable, método, clase)
- Presiona `<leader>ca` (Espacio + c + a)
- Si no aparece nada, puede que no haya refactorings disponibles en ese contexto
