# Instalação do Gentoo
## LVM + Dm-Crypt + BIOS Legacy Mode
### OpenRC + Desktops minimal: como Exemplo: (i3) 
Uma tentativa de traduzir e replicar o melhor possível e de forma suscinta o manual de <b>Sakaki</b>  a esta máquina: Ler mais detalhes em: https://wiki.gentoo.org/wiki/Sakaki%27s_EFI_Install_Guide 
Esta máquina **ThinkpadT420**, não suporta UEFI inteiramente. Desativar UEFI na BIOS. 
### Este repositório serve como guia de ajuda para a instalação do Gentoo-Linux.
Notas:<br>
01: 'É mais fácil fazer clone do meu guia pessoal, em vez de "saltitar" na documentação original.' <br>
02: Lembrar que o LiveCD deve ser de 32Bits (x86) caso a arquitectura original da máquina seja igualmente de 32Bits (x86)<br>
03: Fazer download de um LiveCD e criar uma USB / CD / DVD com a imagem.<br>
```bash
dd if=imagem_x64.iso of=/dev/sd(X) bs=2M status=progress && sync 
```
Configurar a Bios para fazer boot da USB com um LiveCD.<br>
Modo Paranoico: Formatar o disco principal<br>
```bash
dd if=/dev/urandom of=/dev/sd(x) bs=2M && sync 
dd if=/dev/zero of=/dev/sd(x) bs=2M && sync
```
Preparar disco principal:<br>
Usar o fdisk / cfdisk / parted (UEFI) / GPT<br>
```bash
cfdisk /dev/sd(x)
```
Definir:<br>
+2M Espaço para o Grub: /dev/sdX(1)<br> 
+128M espaço para os ficheiros de arranque: /dev/sdX(2)<br>  
<b>Nota</b>: Se a máquina suportar UEFI esta partição deverá estar formatada em FAT32 mas neste caso, a BIOS não suporta UEFI. 
<br>O método antigo continua a funcionar (legacy) > EXT2/3/4/etc<br>
++ O resto fica para o LVM encriptado? Vamos considerar que sim. /dev/sdX(3). <br>Definir sequencia alfanumérica como palavra pass de encriptação do disco em questão.<br>
```bash
cryptsetup -v -y -c aes-xts-plain64 -s 512 -h sha512 -i 5000 --use-random luksFormat /dev/sdX(3)
```
Formatar partição de arranque (/dev/sdX(2))
```bash
mkfs.ext2/3/4 /dev/sdX(2)
```
Fazer dump do disco encriptado e salvar o resultado num ficheiro com a extensão txt.<br>
Abrir o acesso ao disco para fazer partição do disco em modo LVM
```bash
cryptsetup luksDump /dev/sda3 > discoDump.txt
cryptsetup luksOpen /dev/sda3 Gentoo
```
Criar partições na estrutura LVM e activa-las<br>
```bash
lvmdiskscan
pvcreate /dev/mapper/gentoo
pvdisplay
vgcreate gentoo /dev/mapper/gentoo
vgdisplay
lvcreate -C y -L 4G gentoo -n swap
lvcreate -L 10GB gentoo -n root
lvcreate -l +100%FREE gentoo -n home
lvdisplay
vgscan
vgchange -ay
```
Formatar partições definidas na tabela LVM<br>
```bash
mkswap /dev/mapper/gentoo-swap
mkfs.ext4 /dev/mapper/gentoo-root
mkfs.ext4 /dev/mapper/gentoo-home
```
Activar e associar as partições de disco criadas na tabela LVM 
```bash
swapon /dev/mapper/gentoo-swap
mkdir /mnt/gentoo
mount /dev/mapper/gentoo-root /mnt/gentoo
kdir /mnt/gentoo/boot
mkdir /mnt/gentoo/home
mount /dev/sda2 /mnt/gentoo/boot
mount /dev/mapper/gentoo-home /mnt/gentoo/home
```
Fazer download da raíz de ficheiros do Gentoo-Linux e verificar a assinatura de qualidade
```bash
cd /mnt/gentoo
links gentoo.org/main/en/mirrors.xml
download Stage3 tarball
gpg --keyserver pool.sks-keyservers.net --recv-key 2D182910 
gpg --keyserver hkp://pool.sks-keyservers.net:80 --recv-key 2D182910 
gpg --fingerprint 2D182910 
gpg --verify stage3-amd64-*.tar.xz.DIGESTS.asc 
awk '/SHA512 HASH/{getline;print}' stage3-amd64-*.tar.xz.DIGESTS.asc | sha512sum --check 
```
Descompactar ficheiro comprimido com o nome 'stage3'
```bash
tar xpJf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
```
Editar o principal ficheiro de configuração dos sistemas Gentoo
```bash
nano -w /mnt/gentoo/etc/portage/make.conf
```
Associar ficheiro de configuração da sincronização dos repositórios públicos  
```bash
mkdir -p -v /mnt/gentoo/etc/portage/repos.conf
cp -v /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf 
```
Copiar ficheiro de DNS para a partição da instalação.
```bash
cp -v -L /etc/resolv.conf /mnt/gentoo/etc/
```
Associar sistemas de ficheiro de acesso a pontos de hardware
```bash
mount -v -t proc none /mnt/gentoo/proc 
mount -v --rbind /sys /mnt/gentoo/sys 
mount -v --rbind /dev /mnt/gentoo/dev 
mount -v --make-rslave /mnt/gentoo/sys
mount -v --make-rslave /mnt/gentoo/dev
```
A partição está pronta: fazer chroot para iniciar a instalação
```bash
chroot /mnt/gentoo /bin/bash -l
```
Definir palavra de acesso para o utilizador "root"
```bash
passwd
```
Actualizar sistema e sincronizar Metadata da lista de software disponíveis
```bash
env-update && source /etc/profile && export PS1="(chroot) $PS1" 
emerge --sync 
```
Escolher um perfil de instalação
```bash
eselect profile list
eselect profile set 27 # hardened nomultilib
```
Actualizar a aplicação Portage: <br>Ler mais na documentação em<br> <b>https://dev.gentoo.org/~zmedico/portage/doc/</b><br>Ou no directório /usr/share/portage/doc/
```bash
emerge --ask --verbose --oneshot portage
```
Instalar ferramentas úteis para a instalação
```bash
emerge --ask --verbose portage-utils gentoolkit
```
Definir e configurar região geográfica para definir as Horas e os dias
```bash
echo "Europe/Lisbon" > /etc/timezone
emerge -v --config sys-libs/timezone-data
```
Definir Língua, Caractéres do sistema e actualizar definição 
```bash
nano -w /etc/locale.gen
locale-gen 
eselect locale set "C"
env-update && source /etc/profile && export PS1="(chroot) $PS1"
```
Definir Layout / Língua de INPUT do teclado
```bash 
nano -w /etc/conf.d/keymaps # pt-latin9
```
Atribuir nome da máquina
```bash
nano -w /etc/conf.d/hostname # ThinkAbout
```
Configurar o ficheiro /etc/portage/make.conf<br>
<b>CPU</b> Referencia Original:<br> https://wiki.gentoo.org/wiki/Safe_CFLAGS<br>
Bom exemplo encontra-se em: <i>/usr/share/portage/config/make.globals</i><br><br>
Pensar as USE flags do ficheiro /etc/portage/make.conf a usar.<br>
<b>Sample usado</b>:
```bash
COMMON_FLAGS="-O2 -pipe -march=sandybridge"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"
FFLAGS="${COMMON_FLAGS}"
CPU_FLAGS_X86="aes avx mmx mmxext pclmul popcnt sse sse2 sse3 sse4_1 sse4_2 ssse3"
MAKEOPTS="-j5"
# USE FLAGS 
USE="-ipv6 -bindist vim-pager vim-syntax vim"
# Features
FEATURES="split-elog buildpkg"
# Licenses
ACCEPT_LICENSE="-* @FREE"
# Video Card
VIDEO_CARDS="intel i915"
# Audio Card
ALSA_CARDS="snd-hda-intel"
# Inputs
INPUT_DEVICES="libinput"
# Keywords
ACCEPT_KEYWORDS="amd64" # only stable versions
# Grub
GRUB_PLATFORMS="pc"
# LLVM Targets
LLVM_TARGETS="x86 BPF"
# Portage system
PORTAGE_ELOG_CLASSES="info warn error log qa"
PORTAGE_ELOG_SYSTEM="echo save"
EMERGE_DEFAULT_OPTS="--ask --verbose"
PORTAGE_NICENESS=10
PORTDIR="/var/db/repos/gentoo"
DISTDIR="/var/cache/distfiles"
PKGDIR="/var/cache/binpkgs"
LC_MESSAGES=C
```
Ao fazer alterações nas propriedades do USE...<br>
<b>Este passo é recomendado!</b><br>
Fazer <b>bootstrap</b> do sistema.<br>
Ler mais detalhes na documentação original: <br>
https://wiki.gentoo.org/wiki/Sakaki%27s_EFI_Install_Guide/Building_the_Gentoo_Base_System_Minus_Kernel
```bash
emerge -1euNDav @world 
```
<b>Nota</b>: Usar **equery u ?** para ler as flags associadas a cada libraria ou aplicação a instalar.<br>
<b>Nota</b>: Usar **euse <b>-p</b> (Categoria/Aplicação)) <b>-E</b> novas-flags** para adicionar<br>
<b>Nota</b>: Usar **euse <b>-p</b> (Categoria/Aplicação) <b>-D</b> novas-flags** para remover <br><br>
Aplicações necessárias a instalar:<br>

```bash
euse -p sys-boot/grub -E device-mapper mount truetype fonts themes
euse -p dev-libs/boost python numpy tools icu
euse -p sys-kernel/linux-firmware -E savedconfig redistributable
euse -p sys-kernel/genkernel -E firmware
euse -p net-misc/dhcp -E client server ssl vim-syntax
euse -p sys-apps/pciutils -E kmod udev zlib
euse -p sys-apps/pciutils -D dns
euse -p sys-kernel/linux-firmware -E savedconfig
emerge -av sys-boot/grub sys-kernel/gentoo-sources sys-kernel/genkernel net-misc/dhcp sys-kernel/linux-firmware sys-boot/grub sys-apps/pciutils media-gfx/grub-splashes mirrorselect
```
Opcionalmente configurar e instalar:
```bash
euse -p www-client/elinks -E gpm
euse -p dev-vcs/git -D webdav
euse -p net-irc/irssi -E otr socks5
euse -p app-editors/vim -E vim-pager cscope python lua luajit ruby
euse -p app-misc/vifm -E extended-keys magic vim vim-syntax
emerge -av tmux vim vifm eix elinks git irssi

```
Antes de tudo, gostaria de lembrar que podemos usar o 'irssi' e ligarmo-nos ao servidor de <b>IRC</b> da <b>Freenode</b> e entrar no canal <b>#Gentoo</b> de modo a termos suporte directo e rápido na instalação do Gentoo via devenvolvedores do sistema e como tal, pessoas com experiência. Aconselho vivamente, pois foram sempre uma ajuda precisosa!<br> 
Iniciar configuração do kernel para ser possível arrancar o sistema operativo:<br>
Editar o ficheiro <i>/etc/fstab</i> para o reconhecimento da tabela de partições:<br>
Editar o ficheiro <i>/etc/genkernel.conf</i> e executar o comando:<br>
<b>Nota: configurar '"MENUCONFIG="yes"'</b><br>
O comando 'lspci -k' ajuda-nos a configurar o Kernel<br>
Deixo um exemplo de configuração do <i>genkernel.conf</i><br>
```bash
OLDCONFIG="yes"
MENUCONFIG="yes"
NCONFIG="no"
CLEAN="no"
MRPROPER="no"
MOUNTBOOT="yes"
SAVE_CONFIG="yes"
USECOLOR="yes"
MAKEOPTS="-j5"
LVM="yes"
LUKS="yes"
BUSYBOX="yes"
UDEV="yes"
E2FSPROGS="yes"
BOOTLOADER="grub"
SPLASH="yes"
SPLASH_THEME="gentoo"
PLYMOUTH="yes"
PLYMOUTH_THEME="spinner"
GK_SHARE="${GK_SHARE:-/usr/share/genkernel}"
CACHE_DIR="/var/cache/genkernel"
DISTDIR="/var/lib/genkernel/src"
LOGFILE="/var/log/genkernel.log"
DEFAULT_KERNEL_SOURCE="/usr/src/linux"
LOGLEVEL=1
COMPRESS_INITRD_TYPE="best"
REAL_ROOT="/dev/mapper/gentoo-root"
```
Em seguida fazemos <i>mount</i> da partição boot e iniciamos o genkernel
```bash
mount /dev/sdX(2) /boot
genkernel all
```
Antes de instalar o grub no disco deve-se preparar o grub.<br>
Configurar o grub para fazer boot de partições encriptadas que usam LVM e o ficheiro fstab<br>
Deixo um exemplo do ficheiro fstab
```bash
/dev/sda2					                /boot		ext4		noauto,noatime	1 2
UUID=0d179bf0-cb03-48e4-91ff-3558ae25d281	/   		ext4		defaults		0 1
UUID=7c5efc78-1634-440a-934d-8ae80aad4305	/usr		ext4		defaults		0 1
UUID=f8eafdd6-7b70-468a-a734-3132313f6110	/var		ext4		defaults		0 1
UUID=79bdff9f-b384-41de-a139-bb4e9d33aac9	/tmp		ext4		defaults		0 1
UUID=7d77a985-3920-4536-9af4-d0b32fd306f4	/home		ext4		defaults		0 1
UUID=f38b1368-c23c-4621-a58d-6436fc2701c3	none		swap
```
Editar o ficheiro das configurações do grub
```bash
nano /etc/default/grub
GRUB_DISTRIBUTOR="Gentoo"
GRUB_PRELOAD_MODULES=lvm
GRUB_ENABLE_CRYPTODISK=y
GRUB_DEVICE=/dev/ram0
GRUB_CMDLINE_LINUX="crypt_root=UUID=d33f6428-bc13-484b-9675-310l0d5o98e4 real_root=/dev/mapper/gentoo-root rootfstype=ext4 dolvm quiet splash net.ifnames=0"
```
Instalar o grub
```bash 
grub-install /dev/sdX
grub-mkconfig -o /boot/grub/grub.cfg
```
Reiniciar a máquina?<br>
Opcionalmente poderiamos reiniciar o computador. <br>
Vamos considerar continuar a fazer a instalação sem reiniciar, logo agora que ainda não temos ambiente gráfico. A comunidade do Gentoo Linux aconselha a instalação de alguns pacotes:
```bash
emerge cronie syslog-ng laptop-mode irqbalance hddtemp lm_sensors
rc-update add cronie default
rc-update add syslog-ng default
rc-update add laptop-mode default
rc-update add irqbalance default
rc-update add hddtemp default
rc-update add lm-sensors default
```

## Preparação do X + Fontes + formatos de Imagem + audio

## Xorg + i3
