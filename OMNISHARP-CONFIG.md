# OmniSharp - Configuración para C# 12+

## Archivos de Configuración

He creado dos archivos que trabajan juntos para dar sugerencias modernas:

### 1. `.editorconfig` (Ya existente)
Contiene las reglas de estilo de código de C# 12+:
- File-scoped namespaces (`namespace Foo;`)
- Uso de `var` cuando el tipo es obvio
- Braces opcionales para statements de una línea
- Pattern matching moderno
- Expression-bodied members
- Y más...

### 2. `omnisharp.json` (Nuevo)
Configuración específica de OmniSharp:
- ✅ **Habilita soporte de `.editorconfig`**
- ✅ **Activa analizadores de Roslyn** (para sugerencias modernas)
- ✅ **Inlay hints** (muestra tipos implícitos)
- ✅ **Import completion** (auto-importa namespaces)
- ✅ **Decompilation support** (ver código fuente de librerías)

## Cómo Funciona

OmniSharp ahora leerá ambos archivos y:

1. **Respetará las convenciones del `.editorconfig`**
2. **Sugerirá refactorings modernos** (via analizadores de Roslyn)
3. **No te molestará con sugerencias antiguas** como:
   - ❌ "Add braces" en if de una línea
   - ❌ "Use explicit type" cuando usas `var`
   - ❌ "Use namespace with braces" cuando usas file-scoped

## Probar las Sugerencias

Abre Helix en tu proyecto:

```bash
cd ~/github/n-bodies-sim
hx Program.cs
```

**Prueba escribiendo código moderno:**

```csharp
namespace MyApp;  // ✅ File-scoped namespace

public class Example
{
    // ✅ Usar var
    public void Method()
    {
        var number = 42;
        var text = "hello";

        // ✅ If sin braces (una línea)
        if (number > 0)
            Console.WriteLine(text);

        // ✅ Expression-bodied member
        var result = GetValue();
    }

    // ✅ Expression-bodied property
    public int Value => 42;

    // ✅ Expression-bodied method
    private int GetValue() => Value * 2;
}
```

OmniSharp **NO** sugerirá cambios a código moderno como este.

## Sugerencias que SÍ Verás

OmniSharp sugerirá mejoras útiles como:

✅ **Usar características más nuevas:**
- `List<int> list = new();` → Implicit object creation
- `var item = list[^1];` → Index operator
- `var slice = list[1..^1];` → Range operator

✅ **Pattern matching:**
- `if (obj is string s)` → Pattern matching
- `switch` → `switch expression`

✅ **Null checks modernos:**
- `if (x != null)` → `if (x is not null)`
- `x?.Method()` → Null-conditional operator

✅ **Refactorings útiles:**
- Extract method
- Inline variable
- Generate constructor
- Add using statement

## Ubicación de los Archivos

```
~/github/n-bodies-sim/
├── .editorconfig           ← Reglas de estilo
├── omnisharp.json          ← Configuración de OmniSharp
├── *.csproj               ← Proyecto
└── *.cs                   ← Archivos de código
```

## Aplicar a Otros Proyectos

Para que otros proyectos C# tengan la misma configuración:

```bash
# Copiar archivos al proyecto
cp ~/github/n-bodies-sim/.editorconfig ~/otro-proyecto/
cp ~/github/n-bodies-sim/omnisharp.json ~/otro-proyecto/
```

O mejor, créalos en la raíz de tu carpeta de proyectos:

```bash
# Si todos tus proyectos están en ~/github/
cp ~/github/n-bodies-sim/.editorconfig ~/github/
cp ~/github/n-bodies-sim/omnisharp.json ~/github/
```

Así todos los proyectos heredarán la configuración.

## Verificar que Funciona

### En Helix:

1. Abre un archivo C#: `hx Program.cs`
2. Escribe código "antiguo" como:
   ```csharp
   namespace MyApp {  // Namespace con braces
       public class Test {
           public void Method() {
               string text = "hello";  // Tipo explícito
           }
       }
   }
   ```
3. OmniSharp debería sugerir:
   - Cambiar a file-scoped namespace
   - Cambiar a `var`

### En Neovim:

Roslyn ya está configurado correctamente, pero también respeta estos archivos.

## Inlay Hints

Si quieres ver hints de tipos implícitos (opcional):

En Helix, edita `~/.config/helix/config.toml`:

```toml
[editor.lsp]
display-inlay-hints = true
```

Esto mostrará hints como:
```csharp
var number = 42;  // : int
```

## Resumen

✅ **OmniSharp configurado** para C# 12+
✅ **Sugerencias modernas** activadas
✅ **Respeta `.editorconfig`**
✅ **Analizadores de Roslyn** habilitados
✅ **Funciona en Helix y Neovim**

Ahora OmniSharp te dará sugerencias basadas en las mejores prácticas de C# 12+, no en convenciones antiguas.
