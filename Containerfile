FROM quay.io/fedora/fedora-bootc:44

# Estrutura de persistência
RUN mkdir -p /var/roothome /data /var/home /etc/bootc

# Configuração de atualização automática (aponta para o seu repo no GHCR)
RUN echo 'image = "ghcr.io/SEU_USUARIO_GITHUB/sistema-gamer-dev:latest"' > /etc/bootc/config.toml

RUN <<EOF
# Ajusta /opt e /usr/local para serem graváveis
rm -rf /opt && mkdir /var/opt && ln -s /var/opt /opt
mkdir /var/usrlocal
mv /usr/local /usr/local_old && ln -s /var/usrlocal /usr/local
mv /usr/local_old/* /usr/local/ && rm -rf /usr/local_old

# 1. BASE KDE PLASMA (Minimalista)
dnf5 install -y --setopt=install_weak_deps=False \
    plasma-desktop plasma-workspace-wayland plasma-login-manager \
    ptyxis nautilus nautilus-extensions adwaita-icon-theme \
    plasma-nm plasma-pa powerdevil \
    discover packagekit-qt6

# 2. PACOTES GAMER & DRIVERS
dnf5 install -y --setopt=install_weak_deps=False \
    steam wine gamemode mangohud \
    mesa-vulkan-drivers vulkan-intel vulkan-radeon \
    steam-devices xorg-x11-server-Xwayland

# 3. UTILITÁRIOS ESSENCIAIS
dnf5 -y install @networkmanager-submodules @multimedia \
    compsize usbutils distrobox toolbox micro \
    wget tree git fastfetch zram-generator \
    langpacks-core-pt_BR langpacks-pt_BR langpacks-fonts-pt \
    bash-color-prompt tuned tuned-ppd flatpak podman \
    plymouth plymouth-system-theme plymouth-theme-spinner

# 4. KERNEL CACHYOS (Baixa latência)
dnf5 -y copr enable bieszczaders/kernel-cachyos
dnf5 -y swap kernel kernel-cachyos kernel-cachyos-devel-matched

# 5. OTIMIZAÇÕES DE SISTEMA (Sysctl + Módulos)
mkdir -p /etc/modules-load.d
echo "intel_powerclamp" > /etc/modules-load.d/otimizacao-cpu.conf
echo -e "vm.swappiness=10\nvm.max_map_count=2147483642\nnet.core.default_qdisc=fq_pie" > /etc/sysctl.d/99-gamer.conf
EOF

# 6. CONFIGURAÇÃO DE PADRÕES E SERVIÇOS
RUN <<ELF
# Define Nautilus e Ptyxis como padrão
mkdir -p /etc/xdg
echo -e "[Default Applications]\ninode/directory=nautilus.desktop\nx-scheme-handler/terminal=org.gnome.Ptyxis.desktop" > /etc/xdg/mimeapps.list

# Define Ptyxis como terminal padrão no KDE
mkdir -p /etc/skel/.config
echo -e "[General]\nTerminalApplication=ptyxis" > /etc/skel/.config/kdeglobals

# Garantir que o módulo problemático esteja na blacklist
RUN mkdir -p /etc/modprobe.d && \
    echo "blacklist intel_powerclamp" > /etc/modprobe.d/blacklist-cpu.conf && \
    echo "install intel_powerclamp /bin/true" >> /etc/modprobe.d/blacklist-cpu.conf

# Habilita serviços
systemctl enable plasmalogin.service bootc-fetch.timer zram-swap.service
systemctl mask systemd-remount-fs.service

# Injeta parâmetros de kernel (kargs)
mkdir -p /usr/lib/bootc/kargs.d
echo 'kargs = ["intel_pstate=active", "mitigations=off", "nowatchdog"]' > /usr/lib/bootc/kargs.d/01-otimizacao.toml
ELF
