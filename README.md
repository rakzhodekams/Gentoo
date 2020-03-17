# Instalação do Gentoo

Documentação do Portage: https://dev.gentoo.org/~zmedico/portage/doc/<br>
Este repositório serve como guia de ajuda. <br>
Nota: 'É mais fácil fazer clone do meu guia pessoal, em vez de "saltitar" na documentação original.' <br>
Lembrar que o LiveCD deve ser de 32Bits (x86) caso a arquitectura original da máquina seja igualmente de 32Bits (x86)<br>
Fazer download de um LiveCD e criar uma USB / CD / DVD com a imagem.<br>
```bash 
# dd if=imagem_x64.iso of=/dev/sd(X) bs=2M status=progress && sync 
```
Configurar a Bios para fazer boot da USB com um LiveCD.<br>
Modo Paranoico: Formatar o disco principal<br>
```bash
# dd if=/dev/urandom of=/dev/sd(x) bs=2M && sync 
# dd if=/dev/zero of=/dev/sd(x) bs=2M && sync
```
Preparar disco principal:<br>
Usar o fdisk / cfdisk / parted (UEFI) / GPT<br>
+2M Espaço para o Grub: /dev/sdX(1)<br> 
+128M espaço para os ficheiros de arranque: /dev/sdX(2)<br>  
<b>Nota</b>: Se a máquina suportar UEFI esta partição deverá estar formatada em FAT32.<br>
++ O resto fica para o LVM encriptado? Vamos considerar que sim. /dev/sdX(3)<br>
```bash
# cryptsetup -v -y -c aes-xts-plain64 -s 512 -h sha512 -i 5000 --use-random luksFormat /dev/sdX(3)
```
Definir sequencia alfanumérica como palavra pass de encriptação do disco em questão.<br>
```bash
# cryptsetup luksDump /dev/sda3 > discoDump.txt
# cryptsetup luksOpen /dev/sda3 Gentoo
# lvmdiskscan
# pvcreate /dev/mapper/gentoo
# pvdisplay
# vgcreate gentoo /dev/mapper/gentoo
# vgdisplay
# lvcreate -C y -L 4G gentoo -n swap
# lvcreate -L 10GB gentoo -n root
# lvcreate -l +100%FREE gentoo -n home
# lvdisplay
# vgscan
# vgchange -ay
# mkswap /dev/mapper/gentoo-swap
# mkfs.ext4 /dev/mapper/gentoo-root
# mkfs.ext4 /dev/mapper/gentoo-home
# swapon /dev/mapper/gentoo-swap
# mkdir /mnt/gentoo
# mount /dev/mapper/gentoo-root /mnt/gentoo
# mkdir /mnt/gentoo/boot
# mkdir /mnt/gentoo/home
# mount /dev/sda2 /mnt/gentoo/boot
# mount /dev/mapper/gentoo-home /mnt/gentoo/home
# lsblk /dev/sda
# cd /mnt/gentoo
# links gentoo.org/main/en/mirrors.xml
# download Stage3 tarball
# gpg --keyserver pool.sks-keyservers.net --recv-key 2D182910 
# gpg --keyserver hkp://pool.sks-keyservers.net:80 --recv-key 2D182910 
# gpg --fingerprint 2D182910 
# gpg --verify stage3-amd64-*.tar.xz.DIGESTS.asc 
# awk '/SHA512 HASH/{getline;print}' stage3-amd64-*.tar.xz.DIGESTS.asc | sha512sum --check 
# tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
# rm stage3* 
# nano -w /mnt/gentoo/etc/portage/make.conf
```
Configurar o ficheiro make.conf<br>
<b>CPU</b> Referencia Original: https://wiki.gentoo.org/wiki/Safe_CFLAGS<br>
Bom exemplo <i>offline</i>: /usr/share/portage/config/make.globals<br>
```bash
# mkdir -p -v /mnt/gentoo/etc/portage/repos.conf
# cp -v /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf 
# cp -v -L /etc/resolv.conf /mnt/gentoo/etc/
# mount -v -t proc none /mnt/gentoo/proc 
# mount -v --rbind /sys /mnt/gentoo/sys 
# mount -v --rbind /dev /mnt/gentoo/dev 
# mount -v --make-rslave /mnt/gentoo/sys
# mount -v --make-rslave /mnt/gentoo/dev
# chroot /mnt/gentoo /bin/bash -l
# env-update && source /etc/profile && export PS1="(chroot) $PS1" 
# emerge --sync 
# eselect profile list
# emerge --ask --verbose --oneshot portage 
# emerge --ask --verbose portage-utils gentoolkit
# echo "Europe/Lisbon" > /etc/timezone 
# emerge -v --config sys-libs/timezone-data
# nano -w /etc/locale.gen
# locale-gen 
# eselect locale set "C" 
# env-update && source /etc/profile && export PS1="(chroot) $PS1" 
# nano -w /etc/conf.d/keymaps
# nano -w /etc/conf.d/hostname
# nano -w /etc/conf.d/hwclock 
# echo "sys-kernel/linux-firmware linux-fw-redistributable no-source-code" >> /etc/portage/package.license/linux-firmware 
# 






## Modo Minimal ( sem interface gráfica ) : Recomendações
:

Mutt: http://www.mutt.org/doc/manual/

## Xorg + i3

### Tweek
Icons e Fontes: https://www.nerdfonts.com/

