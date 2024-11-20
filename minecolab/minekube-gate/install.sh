#!/bin/bash
set -e

# Variables
REPO_OWNER="minekube"
REPO_NAME="gate"
INSTALL_DIR="$(pwd)"
TEMP_DIR="/tmp/${REPO_NAME}-installer"

# Funciones para imprimir mensajes con colores
print_info() {
    echo -e "\033[0;32m$1\033[0m"
}

print_error() {
    echo -e "\033[0;31m$1\033[0m"
}

# Detectar la arquitectura del sistema
detect_arch() {
    local arch
    arch=$(uname -m)
    case $arch in
        x86_64) echo "amd64" ;;
        aarch64|arm64) echo "arm64" ;;
        i386|i686) echo "386" ;;
        *) 
            print_error "Arquitectura no compatible: $arch"
            exit 1 
            ;;
    esac
}

# Detectar el sistema operativo
detect_os() {
    local os
    os=$(uname -s)
    case $os in
        Linux) echo "linux" ;;
        Darwin) echo "darwin" ;;
        *)
            print_error "Sistema operativo no compatible: $os"
            exit 1
            ;;
    esac
}

# Función principal para instalar la última versión
install_latest_release() {
    print_info "✨ Instalando la última versión de ${REPO_NAME}..."

    mkdir -p "$TEMP_DIR"

    OS=$(detect_os)
    ARCH=$(detect_arch)

    # Obtener la URL de la última release desde GitHub
    LATEST_RELEASE_URL=$(curl -fsSL -o /dev/null -w "%{redirect_url}" "https://github.com/$REPO_OWNER/$REPO_NAME/releases/latest")
    VERSION=$(echo "$LATEST_RELEASE_URL" | sed -E 's|.*/v([^/]+)/.*|\1|')

    if [ -z "$VERSION" ]; then
        print_error "Error al detectar la última versión."
        exit 1
    fi

    # Definir la URL de descarga
    BINARY_NAME="gate_${VERSION}_${OS}_${ARCH}"
    DOWNLOAD_URL="https://github.com/$REPO_OWNER/$REPO_NAME/releases/download/v${VERSION}/${BINARY_NAME}"
    TEMP_FILE="$TEMP_DIR/$BINARY_NAME"

    # Descargar el archivo binario
    print_info "📥 Descargando ${REPO_NAME} ${VERSION} para ${OS}-${ARCH}..."
    wget -q "$DOWNLOAD_URL" -O "$TEMP_FILE"
    
    # Mover el archivo binario a la ruta de instalación
    mv "$TEMP_FILE" "$INSTALL_DIR/${REPO_NAME}"
    chmod +x "$INSTALL_DIR/${REPO_NAME}"

    # Mensaje de éxito
    print_info "✨ ¡${REPO_NAME} ${VERSION} instalado exitosamente en ${INSTALL_DIR}/${REPO_NAME}!"
}

# Ejecutar la instalación
install_latest_release
