# Configuración de Auto-guardado

## Cómo Funciona

El auto-guardado está **activado por defecto** y guarda tus archivos automáticamente en estos casos:

✅ **Al salir del modo insertar** (después de escribir)
✅ **Al cambiar de buffer** (cuando abres otro archivo)
✅ **Al perder el foco** (cuando cambias a otra aplicación)
✅ **Después de cambios en el texto** (1 segundo después del último cambio)

## Comportamiento

- **No muestra mensajes** molestos tipo "AutoSave: saved at..."
- **Espera 1 segundo** después de tu último cambio antes de guardar
- **Solo guarda el archivo actual**, no todos los buffers abiertos
- **No guarda archivos de solo lectura** o especiales (como terminales)

## Activar/Desactivar

### Atajo rápido:
```
Espacio + u + a
```

Esto activa/desactiva el auto-guardado al vuelo.

### Desactivar permanentemente:

Edita `~/.config/nvim/lua/plugins/autosave.lua`:
```lua
opts = {
  enabled = false,  -- Cambiar a false
}
```

## Personalización

### Cambiar el tiempo de espera

Si 1 segundo te parece muy rápido:

```lua
-- En ~/.config/nvim/lua/plugins/autosave.lua
opts = {
  debounce_delay = 3000,  -- 3 segundos (cambiar valor)
}
```

### Solo guardar al cambiar de buffer/aplicación

Si no quieres que guarde mientras escribes:

```lua
opts = {
  trigger_events = {
    immediate_save = { "BufLeave", "FocusLost" },
    defer_save = {},  -- Vaciar este array
  },
}
```

### Guardar TODOS los buffers abiertos

Si quieres que guarde todos los archivos abiertos a la vez:

```lua
opts = {
  write_all_buffers = true,  -- Cambiar a true
}
```

### Mostrar mensajes de guardado

Si quieres ver un mensaje cada vez que guarda:

```lua
opts = {
  execution_message = {
    enabled = true,  -- Cambiar a true
    message = "Guardado automáticamente",
  },
}
```

### Excluir tipos de archivo

Si quieres que NO guarde ciertos tipos de archivos:

```lua
opts = {
  condition = function(buf)
    local fn = vim.fn
    local filetype = fn.getbufvar(buf, "&filetype")

    -- No guardar estos tipos de archivo
    local exclude = { "markdown", "text" }

    if vim.tbl_contains(exclude, filetype) then
      return false  -- No guardar
    end

    return fn.getbufvar(buf, "&modifiable") == 1
  end,
}
```

## Comandos Útiles

```vim
:ASToggle           " Activar/desactivar auto-guardado
:w                  " Guardar manualmente (siempre funciona)
:wa                 " Guardar todos los buffers manualmente
```

## Casos de Uso

### Workflow recomendado:

1. **Escribes código** normalmente
2. **Sales del modo insertar** (`Esc`)
3. **El archivo se guarda automáticamente** (sin mensaje)
4. **Cambias a otra ventana** → Se guarda antes de cambiar
5. **Pierdes el foco** (cambias a navegador) → Se guarda

### Si prefieres control manual:

```
Espacio + u + a  (desactiva auto-save)
```

Luego usa `:w` para guardar manualmente cuando quieras.

## Ventajas

✅ **Nunca pierdes cambios** por olvido
✅ **No interrumpe el flujo** de trabajo
✅ **Git detecta cambios** inmediatamente
✅ **Compiladores/watchers** ven cambios al instante
✅ **Sin mensajes molestos**

## Desventajas

⚠️ Si experimentas con código y quieres deshacer sin guardar, usa:
- `:e!` - Recargar archivo descartando cambios
- `u` - Deshacer (funciona aunque haya guardado)

## Compatibilidad con Git

El auto-guardado funciona perfectamente con Git:
- Los cambios se reflejan inmediatamente en `git status`
- Puedes hacer commits incrementales mientras trabajas
- Gitsigns muestra cambios en tiempo real

## Tips

1. **Confía en el historial de deshacer (`u`)**: Aunque guarde, puedes deshacer cambios
2. **Usa `git stash`**: Si experimentas mucho, usa stash para guardar temporalmente
3. **Branches para experimentar**: Crea branches para cambios experimentales
4. **Auto-save + Gitsigns**: Verás cambios Git en tiempo real

## Resumen

- **Activado por defecto**: Sí
- **Toggle**: `Espacio` + `u` + `a`
- **Tiempo de espera**: 1 segundo después del último cambio
- **Mensajes**: Desactivados (silencioso)
- **Archivos guardados**: Solo el buffer actual

¡Ahora nunca más perderás cambios por olvidarte de guardar!
