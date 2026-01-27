# Configuración de Notificaciones y Mensajes

## Cambios Realizados

✅ **Las notificaciones duran 5 segundos** (antes ~2 segundos)
✅ **Puedes ver el historial completo** de todas las notificaciones
✅ **Ventanas más grandes** (hasta 80 caracteres de ancho)
✅ **Puedes descartar notificaciones** manualmente

## Atajos de Teclado

### Gestionar Notificaciones

| Atajo | Acción |
|-------|--------|
| `<leader>un` | Cerrar todas las notificaciones activas |
| `<leader>uN` | Ver historial completo de notificaciones |
| `:messages` | Ver todos los mensajes de Vim/Neovim |

**Nota:** `<leader>` = `Espacio`

- `Espacio` + `u` + `n` → Cerrar notificaciones
- `Espacio` + `u` + `N` (mayúscula) → Ver historial

## Ver Mensajes Perdidos

### Opción 1: Historial de Notificaciones (Telescope)
```
Espacio + u + N (mayúscula)
```
- Verás TODAS las notificaciones desde que abriste Neovim
- Navega con `j`/`k`
- Presiona Enter para ver detalles
- Presiona `q` para cerrar

### Opción 2: Mensajes de Vim
```vim
:messages
```
- Muestra todos los mensajes del sistema
- Útil para warnings/errores del inicio
- Scroll con `j`/`k` si hay muchos

### Opción 3: Abrir ventana de mensajes
```vim
:split | messages
```
- Abre los mensajes en una ventana dividida
- Puedes hacer scroll cómodamente

## Tipos de Notificaciones

Las notificaciones tienen diferentes niveles:

- 🔴 **ERROR** - Errores críticos (duran 5s)
- 🟡 **WARN** - Advertencias (duran 5s)
- 🔵 **INFO** - Información (duran 5s)
- 🟢 **TRACE/DEBUG** - Debug info (duran 3s)

## Ejemplos de Uso

### Ver un mensaje que desapareció
1. Presiona `Espacio` + `u` + `N`
2. Busca el mensaje en la lista
3. Presiona Enter para ver detalles completos

### Cerrar notificaciones molestas
1. Presiona `Espacio` + `u` + `n`
2. Todas las notificaciones desaparecen

### Ver errores al inicio
1. Abre Neovim
2. Si viste un error pero desapareció rápido
3. Escribe `:messages` y presiona Enter
4. Verás todo el historial de mensajes

## Configuración Personalizada

### Cambiar duración de notificaciones

Edita `~/.config/nvim/lua/plugins/notifications.lua`:

```lua
opts = {
  timeout = 10000,  -- 10 segundos (cambiar este valor)
}
```

### Desactivar notificaciones flotantes (usar mensajes clásicos)

Si prefieres los mensajes tradicionales de Vim:

```lua
-- Añadir en ~/.config/nvim/lua/config/options.lua
vim.notify = vim.notify  -- Usar notify original
```

## Comandos Útiles

```vim
:messages              " Ver todos los mensajes
:messages clear        " Limpiar historial de mensajes
:Telescope notify      " Ver historial de notificaciones (mismo que <leader>uN)
:Notifications         " Abrir panel de notificaciones
```

## Tips

1. **Si un mensaje desaparece muy rápido**: Presiona `Espacio` + `u` + `N` para verlo de nuevo
2. **Para warnings al inicio**: Usa `:messages` justo después de abrir Neovim
3. **Notificaciones molestas**: Usa `Espacio` + `u` + `n` para cerrarlas
4. **Ver logs completos**: `:checkhealth` muestra estado de todos los plugins

## Solución de Problemas

### Las notificaciones siguen desapareciendo rápido
- Verifica que se haya cargado el archivo: `:lua print(require('notify').setup)`
- Reinicia Neovim

### No veo el historial con <leader>uN
- Instala Telescope notify: `:Lazy sync`
- Verifica: `:Telescope notify`

### Quiero notificaciones más discretas
```lua
-- En notifications.lua
opts = {
  timeout = 3000,
  stages = "static",  -- Sin animaciones
  top_down = true,    # Mostrar arriba
}
```

## Resumen Rápido

**Workflow recomendado cuando pierdes un mensaje:**

1. Mensaje desapareció → `Espacio` + `u` + `N` (ver historial)
2. Error al inicio → `:messages`
3. Demasiadas notificaciones → `Espacio` + `u` + `n` (cerrar todas)

Ya no tendrás que preocuparte por perder mensajes importantes.
