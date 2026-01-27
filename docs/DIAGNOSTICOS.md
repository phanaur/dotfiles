# Guía de Diagnósticos Mejorados

## Cambios Realizados

✅ **Ventanas flotantes automáticas** - Los errores/warnings aparecen automáticamente cuando detienes el cursor sobre ellos (0.5 segundos)
✅ **Ventanas flotantes más grandes** - Los errores ahora se muestran completos (hasta 80 caracteres de ancho, 20 líneas de alto)
✅ **Trouble.nvim activado** - Panel dedicado para ver TODOS los errores/warnings del archivo o proyecto
✅ **Mejores atajos de teclado** - Navega fácilmente entre errores

## Atajos de Teclado

### Ver Errores

| Atajo | Acción |
|-------|--------|
| `gl` | Mostrar error de la línea actual (ventana flotante grande) |
| `<leader>xx` | Abrir panel de errores del archivo actual (Trouble) |
| `<leader>xX` | Abrir panel de errores de todo el proyecto (Trouble) |
| `K` | Mostrar documentación (cuando estás sobre un símbolo) |

### Navegar Entre Errores

| Atajo | Acción |
|-------|--------|
| `]d` | Ir al siguiente diagnóstico (error/warning/hint) |
| `[d` | Ir al diagnóstico anterior |
| `]e` | Ir al siguiente ERROR (solo errores, ignora warnings) |
| `[e` | Ir al error anterior |
| `]q` | Siguiente item en Trouble/Quickfix |
| `[q` | Anterior item en Trouble/Quickfix |

### Dentro del Panel Trouble

Cuando tengas abierto Trouble (`<leader>xx`):

| Atajo | Acción |
|-------|--------|
| `Enter` o `Tab` | Ir al error |
| `o` | Ir al error y cerrar Trouble |
| `q` o `Esc` | Cerrar panel |
| `j` / `k` | Navegar arriba/abajo |
| `K` | Ver más información sobre el error |
| `r` | Refrescar lista |

## Ventana Flotante Automática

**Nuevo comportamiento:** Ahora las ventanas con errores/warnings aparecen automáticamente.

Simplemente:
1. Mueve el cursor a una línea con error/warning (verás subrayado rojo/amarillo)
2. **Espera medio segundo** sin mover el cursor
3. La ventana flotante aparece automáticamente con el mensaje completo
4. Al mover el cursor, la ventana se cierra sola

**Nota:** También puedes presionar `gl` manualmente si quieres verlo al instante.

## Ejemplos de Uso

### Caso 1: Ver un error específico (automático)
1. Pon el cursor sobre una línea con error (verás subrayado rojo)
2. Espera 0.5 segundos sin mover el cursor
3. La ventana flotante aparece automáticamente con el error completo
4. Mueve el cursor y la ventana se cierra

### Caso 2: Ver todos los errores del archivo
1. Presiona `Espacio` + `x` + `x` (abre Trouble con errores del archivo)
2. Navega con `j`/`k`
3. Presiona `Enter` para saltar al error
4. Presiona `q` para cerrar

### Caso 3: Ver errores de todo el proyecto
1. Presiona `Espacio` + `x` + `X` (mayúscula, abre Trouble con todos los errores)
2. Ve todos los errores de todos los archivos
3. Navega y salta a ellos con `Enter`

### Caso 4: Saltar rápidamente entre errores
1. Presiona `]e` para ir al siguiente error
2. Presiona `[e` para volver al anterior
3. Usa `]d` / `[d` si quieres incluir warnings/hints

## Tipos de Diagnósticos

Los diagnósticos se muestran con diferentes iconos y colores:

- 🔴 **Error** () - Problema que impide compilar/ejecutar
- 🟡 **Warning** () - Advertencia que deberías revisar
- 🔵 **Info** () - Información útil
- 💡 **Hint** () - Sugerencia de mejora

## Configuración Adicional

### Ajustar tiempo de aparición automática
Si 0.5 segundos te parece muy rápido o muy lento:

```lua
-- En ~/.config/nvim/lua/plugins/diagnostics.lua
vim.opt.updatetime = 1000  -- 1 segundo (cambiar valor)
-- Valores recomendados: 300-1000 ms
```

### Desactivar ventanas automáticas
Si prefieres solo usar `gl` manualmente:

```lua
-- En ~/.config/nvim/lua/plugins/diagnostics.lua
-- Comentar o eliminar el autocmd CursorHold completo
```

### Desactivar diagnósticos virtuales (inline)
Si prefieres ver errores solo en ventanas flotantes:

```lua
-- En ~/.config/nvim/lua/plugins/diagnostics.lua
vim.diagnostic.config({
  virtual_text = false,  -- Cambiar a false
})
```

### Cambiar tamaño de ventana flotante
```lua
-- En ~/.config/nvim/lua/plugins/diagnostics.lua
float = {
  max_width = 100,  -- Cambiar ancho
  max_height = 30,  -- Cambiar alto
}
```

## Comandos Útiles

```vim
:Trouble                     " Abrir Trouble
:TroubleToggle              " Toggle Trouble
:TroubleToggle workspace_diagnostics  " Errores del workspace
:lua vim.diagnostic.setloclist()      " Poner errores en location list
```

## Resumen Rápido

**Workflow recomendado:**

1. **Escribes código** → Ves subrayados rojos/amarillos
2. **Ver detalles**: Simplemente deja el cursor sobre la línea por 0.5 segundos (aparece automáticamente)
3. **Ver todos los errores**: Presiona `Espacio` + `x` + `x`
4. **Navegar rápido**: Usa `]e` y `[e` para saltar entre errores
5. **Arreglar y continuar**

**¡Las ventanas flotantes ahora aparecen automáticamente!** Ya no necesitas presionar `gl` (aunque sigue funcionando si quieres verlo al instante).

Ya no tendrás que lidiar con errores cortados en una línea.
