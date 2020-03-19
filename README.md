# Instalação do Gentoo
## LVM + Dm-Crypt + BIOS Legacy Mode
### OpenRC + Desktops minimal: como Exemplo: (i3) 
Uma tentativa de traduzir e replicar o melhor possível e de forma suscinta o manual de <b>Sakaki</b> <br>
Manual associado a esta máquina: <b>ThinkpadT420</b> https://wiki.gentoo.org/wiki/Sakaki%27s_EFI_Install_Guide 
> Esta máquina **ThinkpadT420**, não suporta UEFI inteiramente. Desativar UEFI na BIOS. 
### Este repositório serve como guia de ajuda para a instalação do Gentoo-Linux. <br>
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
Activar e associar as partições de disco criadas na tabela LVM fisicamente ( no disco /dev/sdX(?) | /dev/mapper/NOME-NOME)
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
Editar o principal ficheiro de configuração dos sistemas Gentoo / FreeBSD
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
Actualizar sistema e sincronizar Metadata da lista de software disponíveis
```bash
env-update && source /etc/profile && export PS1="(chroot) $PS1" 
emerge --sync 
```
Escolher um perfil de instalação
```bash
eselect profile list
```
Actualizar a aplicação Portage: <br>Ler mais na documentação On-Line <b>https://dev.gentoo.org/~zmedico/portage/doc/</b><br>Ou Off-Line /usr/share/portage/docs/
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
<b>CPU</b> Referencia Original: https://wiki.gentoo.org/wiki/Safe_CFLAGS<br>
Bom exemplo <i>offline</i>: /usr/share/portage/config/make.globals<br><br>
Pensar as USE flags do ficheiro /etc/portage/make.conf a usar.<br>
<b>Sample usado</b>:
```bash
# These settings were set by the catalyst build script that automatically
# built this stage.
# Please consult /usr/share/portage/config/make.conf.example for a more
# detailed example.
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
ACCEPT_KEYWORDS="amd64"
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
<b>Nota</b>: Usar **euse <b>-p</b> (PastaArvoreDoPortage(:/var/db/repo/gentoo/)) <b>-E</b> novas-flags para adicionar<br>
<b>Nota</b>: Usar **euse <b>-p</b> (PastaArvoreDoPortage(:/var/db/repo/gentoo/)) <b>-D</b> novas-flags para remover <br><br>
Aplicações necessárias a instalar:<br>
- euse -p sys-boot/grub -E device-mapper mount truetype
    - Associar dependencias (opcional)
        - euse -p dev-libs/boost python numpy tools icu
- sys-kernel/gentoo-sources
- sys-kernel/genkernel
- net-misc/dhcp
```bash
emerge -av sys-boot/grub sys-kernel/gentoo-sources sys-kernel/genkernel net-misc/dhcp
```
Opcionalmente configurar e instalar:
- euse -p www-client/elinks -E bittorrent gpm
- euse -p dev-vcs/git -D webdav
- euse -p net-irc/irssi -E otr socks5
- tmux : 
- vim : 
- vifm : 
- eix 
```bash
emerge -av tmux vim vifm eix elinks git irssi 
```
Iniciar configuração do kernel para ser possível arrancar o sistema operativo<br>
Editar o ficheiro /etc/genkernel.conf e executar o comando:<br>
<b>Nota: configurar para '"MENUCONFIG="yes"'<br>
```bash
mount /dev/sdX(2) /boot
genkernel --all
```
Instalar o grub no disco
```bash 
grub-install /dev/sdX
grub-mkconfig -o /boot/grub/grub.cfg
```
Reboot?
## Preparação do X + Fontes + formatos de Imagem + audio
## Xorg + i3

