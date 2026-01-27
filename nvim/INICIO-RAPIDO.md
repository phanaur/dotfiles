# Inicio Rápido - LazyVim con C# / Roslyn

## Primer Uso (Sigue estos pasos EN ORDEN)

### 1. Abre Neovim
```bash
nvim
```

- Verás plugins instalándose
- **Espera 2-3 minutos** hasta que termine
- Cuando veas el dashboard, continúa

### 2. Instala Roslyn

Escribe estos comandos en orden (presiona Enter después de cada uno):

```vim
:Mason
```

- Cuando se abra la ventana, presiona `/` y escribe `roslyn`
- Presiona Enter
- Mueve el cursor sobre `roslyn` y presiona `i`
- **Espera 5-10 minutos** (Roslyn es grande)
- Cuando veas ✓ verde, presiona `q`

### 3. Prueba con un Proyecto

```vim
:q
```

Sal de Neovim y abre un proyecto C#:

```bash
cd /tmp/test-nvim-csharp
nvim Calculator.cs
```

- Espera 1-2 minutos a que Roslyn se conecte
- Cuando veas mensajes de "roslyn: Ready" en la parte inferior, ¡ya está!

### 4. Prueba Funcionalidades Básicas

Con el archivo abierto:

- **Autocompletado**: Empieza a escribir, verás sugerencias
- **Ir a definición**: `gd` con el cursor sobre algo
- **Code actions**: `Espacio` luego `c` luego `a`
- **Renombrar**: `Espacio` luego `c` luego `r`
- **Explorador archivos**: `Espacio` luego `e`

## ¿Problemas?

- Lee `INSTALAR-ROSLYN.md` para instrucciones detalladas
- Lee `GUIA-CSHARP.md` para atajos y funcionalidades completas

## Configuración Moderna de C#

Copia el `.editorconfig` a tus proyectos:
```bash
cp /tmp/test-nvim-csharp/.editorconfig ~/tu-proyecto/
```

Esto configura:
- File-scoped namespaces
- Uso de `var`
- Braces opcionales
- Y más convenciones de C# 12+

## Resumen de Atajos Principales

- `Espacio` = Tecla líder (presiona y verás un menú)
- `gd` = Ir a definición
- `gr` = Ver referencias
- `K` = Mostrar documentación
- `Espacio` `c` `a` = Code actions (refactoring)
- `Espacio` `c` `r` = Renombrar
- `Espacio` `e` = Explorador de archivos
- `Espacio` `f` `f` = Buscar archivos
- `:q` = Salir

## Próximos Pasos

1. Familiarízate con los atajos presionando `Espacio` y explorando el menú
2. Lee `GUIA-CSHARP.md` para funcionalidades avanzadas
3. Personaliza en `~/.config/nvim/lua/plugins/`
