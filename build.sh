#!/usr/bin/env bash

# Sair imediatamente se algum comando falhar
set -e

echo "🔍 Detectando a distribuição do sistema host..."

# Verifica o arquivo os-release para identificar a distro
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
    # Captura IDs secundários (como 'ubuntu' que herda de 'debian')
    ID_LIKE_VAR=${ID_LIKE:-""}
else
    echo "❌ Erro: Não foi possível detectar a distribuição (os-release ausente)."
    exit 1
fi

echo "Distro detectada: $DISTRO"

# 1. Instalação de dependências no Host
case "$DISTRO" in
    fedora)
        echo "📦 Base Fedora detectada. Instalando o podman via DNF..."
        # Tenta usar o dnf5 se disponível, senão vai de dnf padrão
        if command -v dnf5 &> /dev/null; then
            sudo dnf5 install -y podman
        else
            sudo dnf install -y podman
        fi
        ;;
    arch|archlinux)
        echo "📦 Base Arch Linux detectada. Instalando o podman via Pacman..."
        sudo pacman -Sy --needed --noconfirm podman
        ;;
    debian|ubuntu|pop|mint)
        echo "📦 Base Debian/Ubuntu detectada. Instalando o podman via APT..."
        sudo apt-get update
        sudo apt-get install -y podman
        ;;
    *)
        # Verificação secundária por herança (ID_LIKE)
        if [[ "$ID_LIKE_VAR" == *"arch"* ]]; then
            echo "📦 Derivado do Arch detectado. Instalando via Pacman..."
            sudo pacman -Sy --needed --noconfirm podman
        elif [[ "$ID_LIKE_VAR" == *"debian"* || "$ID_LIKE_VAR" == *"ubuntu"* ]]; then
            echo "📦 Derivado Debian/Ubuntu detectado. Instalando via APT..."
            sudo apt-get update
            sudo apt-get install -y podman
        else
            echo "⚠️ Distro não homologada diretamente para instalação automática."
            echo "Garantindo que você tenha o 'podman' instalado manualmente para continuar."
            if ! command -v podman &> /dev/null; then
                echo "❌ Erro: 'podman' não está instalado no host."
                exit 1
            fi
        fi
        ;;
esac

# 2. Verificação do Containerfile
if [ ! -f "Containerfile" ]; then
    echo "❌ Erro: Arquivo 'Containerfile' não encontrado na pasta atual!"
    echo "Certifique-se de rodar este script de dentro da pasta do projeto."
    exit 1
fi

# 3. Execução do Build com correção de rede integrada
echo "🚀 Iniciando o Podman Build (usando a rede do host para evitar erros de DNS)..."
sudo podman build --network host -t localhost/steamandgear:latest .

echo "✅ Sistema compilado localmente com sucesso como 'localhost/steamandgear:latest'!"
echo "Próximo passo recomendado: Gerar a ISO usando o seu config.toml."
