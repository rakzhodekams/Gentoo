#!/bin/bash
mount /dev/sda1 /boot
cd /usr/src/linux/ && 
make menuconfig && 
make -j5 && make modules -j5 && make modules_install -j5 && make install -j5 && grub-mkconfig -o /boot/grub/grub.cfg  && reboot
