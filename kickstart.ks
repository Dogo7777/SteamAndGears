# Idioma e teclado
lang pt_BR.UTF-8
keyboard br-abnt2
timezone America/Sao_Paulo

# Bootloader
bootloader --location=mbr

# Particionamento
clearpart --all --initlabel
part /boot/efi --fstype=efi --size=512
part /boot --fstype=ext4 --size=1024
part btrfs.01 --fstype=btrfs --grow

# Subvolumes btrfs
btrfs none --label=system btrfs.01
btrfs / --subvol --name=@ LABEL=system
btrfs /var --subvol --name=@var LABEL=system
btrfs /var/home --subvol --name=@var-home LABEL=system
btrfs /var/log --subvol --name=@var-log LABEL=system
btrfs /var/cache --subvol --name=@var-cache LABEL=system
btrfs /var/lib/docker --subvol --name=@docker LABEL=system

# Sem interface gráfica no instalador
text

# Reinicia após instalar
reboot
