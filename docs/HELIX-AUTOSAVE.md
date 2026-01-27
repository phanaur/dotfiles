# Helix - Auto-save Configurado

## ✅ Auto-save Activado

He añadido auto-save a tu configuración de Helix.

## Configuración Aplicada

En `~/.config/helix/config.toml`:

```toml
[editor]
auto-save = true
idle-timeout = 1000  # 1 segundo (1000 ms)
```

## Cómo Funciona

**Helix guardará automáticamente:**
- Después de **1 segundo** sin escribir
- Solo si hay cambios sin guardar
- Silenciosamente (sin mensajes)

## Probar

```bash
hx ~/github/n-bodies-sim/Calculator.cs
```

1. Haz un cambio en el archivo
2. Espera 1 segundo sin escribir nada
3. El archivo se guarda automáticamente (verás el indicador [MODIFIED] desaparecer)

## Personalización

### Cambiar el tiempo de espera

Si 1 segundo te parece muy rápido o muy lento, edita `~/.config/helix/config.toml`:

```toml
[editor]
idle-timeout = 3000  # 3 segundos
```

Valores recomendados:
- **500-1000 ms** - Guardado muy frecuente (bueno para proyectos con hot reload)
- **1000-2000 ms** - Equilibrado (recomendado)
- **3000-5000 ms** - Menos frecuente (si prefieres más control)

### Desactivar auto-save

Si quieres desactivarlo temporalmente o permanentemente:

```toml
[editor]
auto-save = false
```

O comenta la línea:
```toml
[editor]
# auto-save = true
```

### Guardar manualmente

Aunque tengas auto-save activado, siempre puedes guardar manualmente:
- `:w` - Guardar
- `:wa` - Guardar todos los buffers
- `:q` - Salir (guarda automáticamente si hay cambios con auto-save)

## Comparación con Neovim

Ahora ambos editores tienen auto-save:

| Característica | Neovim | Helix |
|---------------|---------|-------|
| Auto-save | ✅ Sí | ✅ Sí |
| Tiempo de espera | 1 segundo | 1 segundo |
| Guarda al cambiar buffer | ✅ Sí | ✅ Sí (con idle-timeout) |
| Guarda al perder foco | ✅ Sí | ✅ Sí |
| Toggle manual | `Espacio + u + a` | Editar config.toml |

## Ventajas del Auto-save

✅ **Nunca pierdes cambios** por olvido
✅ **LSP ve los cambios** inmediatamente
✅ **Git detecta cambios** al instante
✅ **Hot reload funciona** mejor (si usas herramientas de desarrollo)
✅ **Sin interrupciones** - guarda silenciosamente

## Desventajas (y Soluciones)

⚠️ **Experimentar sin guardar:**
- Solución: Usa `:u` para deshacer cambios
- O `:e!` para recargar desde disco

⚠️ **Commits no intencionados:**
- Solución: Usa `git stash` para guardar temporalmente
- O trabaja en branches experimentales

## Comandos Útiles

```
:w        # Guardar manualmente (siempre funciona)
:wa       # Guardar todos los buffers
:q        # Salir (guarda automáticamente con auto-save)
:q!       # Salir sin guardar (forzado)
:e!       # Recargar archivo descartando cambios
:u        # Deshacer (funciona aunque haya guardado)
```

## Tips

1. **Confía en el historial de deshacer (`u`)**: Aunque guarde automáticamente, puedes deshacer cambios
2. **Usa git**: El auto-save funciona muy bien con Git workflows
3. **Hot reload**: Si usas `dotnet watch` o herramientas similares, verán los cambios inmediatamente
4. **No te preocupes**: El auto-save es conservador, solo guarda cuando hay cambios reales

## Estado Actual

```
Helix:
  ✅ Auto-save: Activado
  ✅ Tiempo: 1 segundo
  ✅ OmniSharp LSP configurado
  ✅ Respeta .editorconfig
  ✅ Sugerencias de C# 12+

Neovim:
  ✅ Auto-save: Activado
  ✅ Tiempo: 1 segundo
  ✅ Roslyn LSP configurado
  ✅ Respeta .editorconfig
  ✅ Diagnósticos automáticos
```

¡Ahora tienes auto-save en ambos editores con la misma configuración!
