#!/bin/bash

# Configuración
FONT_NAME="JetBrainsMono"
URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${FONT_NAME}.zip"
TEMP_DIR="/tmp/jb_mono_nerd"
INSTALL_DIR="/usr/share/fonts/jetbrains-mono-nerd"

echo "🚀 Iniciando la instalación global de JetBrains Mono Nerd Font..."

# 1. Verificar dependencias
if ! command -v unzip &> /dev/null || ! command -v wget &> /dev/null; then
    echo "📦 Instalando dependencias necesarias (wget, unzip)..."
    sudo dnf install -y wget unzip
fi

# 2. Crear carpetas temporales y de destino
mkdir -p "$TEMP_DIR"
sudo mkdir -p "$INSTALL_DIR"

# 3. Descargar la fuente
echo "📥 Descargando desde GitHub..."
wget -q --show-progress -O "$TEMP_DIR/font.zip" "$URL"

# 4. Descomprimir
echo "📂 Descomprimiendo archivos..."
unzip -o "$TEMP_DIR/font.zip" -d "$TEMP_DIR"

# 5. Instalar globalmente
echo "🚚 Moviendo fuentes a $INSTALL_DIR..."
# Filtramos solo archivos .ttf y .otf
sudo find "$TEMP_DIR" -name "*.[to]tf" -exec mv {} "$INSTALL_DIR" \;

# 6. Limpiar permisos
sudo chmod 644 "$INSTALL_DIR"/*.[to]tf

# 7. Actualizar el caché de fuentes
echo "🔄 Actualizando el caché del sistema..."
sudo fc-cache -fv

# 8. Limpieza
rm -rf "$TEMP_DIR"

echo "✅ ¡Instalación completada! Ya puedes seleccionar la fuente en tu terminal o IDE."