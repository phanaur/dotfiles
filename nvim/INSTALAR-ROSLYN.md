# Guía de Instalación de Roslyn LSP

## Paso 1: Abrir Neovim

```bash
nvim
```

La primera vez que abras Neovim después de los cambios:
- Verás plugins instalándose automáticamente
- **ESPERA a que termine completamente** (2-3 minutos)
- Verás mensajes de Mason instalando `csharpier`, `fantomas`, etc.
- Cuando termine, verás el dashboard de LazyVim

## Paso 2: Verificar el Registro de Mason

Una vez cargado, escribe:
```
:Mason
```

Presiona Enter. Se abrirá una ventana con herramientas disponibles.

## Paso 3: Buscar Roslyn

En la ventana de Mason:
1. Presiona `/` (barra) para buscar
2. Escribe: `roslyn`
3. Presiona Enter

Deberías ver:
- `roslyn` - Roslyn Language Server (stable)
- `roslyn-unstable` - Roslyn Language Server (bleeding edge)

**Usa `roslyn` (la versión estable)**

## Paso 4: Instalar Roslyn

1. Mueve el cursor sobre `roslyn` con las flechas o `j`/`k`
2. Presiona `i` para instalarlo
3. Verás el progreso de descarga e instalación
4. **ESTO PUEDE TARDAR 5-10 MINUTOS** - Roslyn es un paquete grande (~300MB)
5. Verás mensajes como:
   ```
   downloading roslyn...
   extracting...
   installing...
   ```
6. Cuando termine verás un ✓ verde junto a `roslyn`

## Paso 5: Verificar la Instalación

Una vez instalado:
1. Presiona `q` para salir de Mason
2. Verifica que Roslyn esté instalado:
   ```
   :!ls ~/.local/share/nvim/mason/bin/roslyn
   ```

   Deberías ver el archivo del binario.

## Paso 6: Probar con un Proyecto C#

```bash
:q
```

Sal de Neovim y abre un archivo C#:

```bash
cd /tmp/test-nvim-csharp
nvim Calculator.cs
```

**La primera vez:**
- Roslyn tardará 1-2 minutos en iniciar y analizar el proyecto
- Verás mensajes en la parte inferior como:
  ```
  roslyn: Starting...
  roslyn: Analyzing solution...
  roslyn: Ready
  ```

## Paso 7: Verificar que Funciona

Una vez que Roslyn diga "Ready":

1. **Ver información LSP**:
   ```
   :LspInfo
   ```
   Deberías ver "roslyn" en la lista de clientes activos

2. **Probar autocompletado**:
   - Empieza a escribir código
   - Deberías ver sugerencias automáticas

3. **Probar refactoring**:
   - Pon el cursor sobre una variable
   - Presiona `Espacio` `c` `a` (code actions)
   - Deberías ver opciones de refactoring

## Problemas Comunes

### "roslyn not found" en Mason
- **Solución**: El registro personalizado no se cargó
- Verifica que el archivo `~/.config/nvim/lua/plugins/mason-config.lua` existe
- Cierra Neovim completamente y vuelve a abrirlo
- Ejecuta `:Lazy sync` y espera a que termine

### Roslyn no se conecta
- **Verifica que estés en un proyecto con `.csproj` o `.sln`**
- Ejecuta: `:LspRestart`
- Mira los logs: `:LspLog`

### Instalación muy lenta
- Roslyn es grande (~300MB), es normal que tarde
- Ten paciencia, especialmente en la primera instalación

### "Command not found" al intentar instalar
- Asegúrate de tener `dotnet` instalado:
  ```bash
  dotnet --version
  ```
  Debería mostrar 10.0.102

## Alternativa: Instalación Manual

Si Mason no funciona, puedes instalar Roslyn manualmente:

```bash
# Descargar Roslyn
mkdir -p ~/.local/share/nvim/roslyn
cd ~/.local/share/nvim/roslyn
# Descargar desde: https://github.com/dotnet/roslyn/releases
```

Luego actualiza la configuración para apuntar a esa ubicación.

## Siguiente Paso

Una vez instalado, consulta `GUIA-CSHARP.md` para aprender a usar todas las funcionalidades.
