#!/bin/bash
echo 'THIS SCRIPT MUST BE RUN AS ROOT...'
sleep 1
echo 'Installing SSH and cockpit and adding firewall rules...'
sleep 1
echo 'Cockpit can be found at https://'$HOST':9090'
sleep 1
dnf install cockpit openssh-server -y
firewall-cmd --add-service=ssh --permanent
firewall-cmd --add-service=cockpit --permanent
firewall-cmd --reload
systemctl start sshd
systemctl enable sshd
lspci -k | grep vga -i > /tmp/grep.tmp

dev1=$(cat /tmp/grep.tmp | cut -d ' ' -f 1 | head -n 1)
dev2=$(cat /tmp/grep.tmp | cut -d ' ' -f 1 | head -n 2 | tail -n 1)
echo 'NEED TO COMPLETE AUDIO DEVICE CONFIG'
echo $dev1
echo $dev2
echo $dev3
echo $dev4
echo $dev5
echo $dev6

echo "installing PCI devices $dev1' ' $dev2' ' $dev3' ' $dev4' '$dev5' ' $dev6 to dracut... "
echo """#!/bin/sh
PREREQS=""
DEVS=\"0000:$dev1 0000:$dev2 0000:$dev3 0000:$dev4 0000:$dev5 0000:$dev6\"

for DEV in $DEVS; do
        echo \"vfio-pci\" > /sys/bus/pci/devices/$DEV/driver_override
done

modprobe -i vfio-pci""" > /usr/sbin/vfio-pci-override.sh

mkdir /usr/lib/dracut/modules.d/20vfio

echo """#!/usr/bin/bash
check() {
  return 0
}
depends() {
  return 0
}
install() {
  declare moddir=\${moddir}
  inst_hook pre-udev 00 \"\$moddir/vfio-pci-override.sh\"
}""" > /usr/lib/dracut/modules.d/20vfio/module_setup.sh
 
ln -s /usr/sbin/vfio-pci-override.sh /usr/lib/dracut/modules.d/20vfio/vfio-pci-override.sh

echo """add_dracutmodules+=\" vfio \"
force_drivers+=\" vfio vfio-pci vfio_iommu_type1 \"
install_items=\"/usr/sbin/vfio-pci-override.sh /usr/bin/find /usr/bin/dirname\"""" > /etc/dracut.conf.d/vfio.conf
echo ' '
echo ' '
echo ' '
echo '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
sleep 1
echo ' '
echo "Make sure your output is as such below..."
echo ' '
sleep 1
echo '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'

echo "
    etc/modprobe.d/vfio.conf
    usr/lib/modules/5.2.9-200.fc30.x86_64/kernel/drivers/vfio
    usr/lib/modules/5.2.9-200.fc30.x86_64/kernel/drivers/vfio/pci
    usr/lib/modules/5.2.9-200.fc30.x86_64/kernel/drivers/vfio/pci/vfio-pci.ko.xz
    usr/lib/modules/5.2.9-200.fc30.x86_64/kernel/drivers/vfio/vfio_iommu_type1.ko.xz
    usr/lib/modules/5.2.9-200.fc30.x86_64/kernel/drivers/vfio/vfio.ko.xz
    usr/lib/modules/5.2.9-200.fc30.x86_64/kernel/drivers/vfio/vfio_virqfd.ko.xz
    usr/sbin/vfio-pci-override.sh
"
sleep 1
echo "Checking if dracut added vfio modules to ramFS... "
sleep 1
echo 'lsinitrd | grep vfio' 
lsinitrd | grep vfio
echo  ' '
echo ' '
sleep 1
echo 'If you saw what was referenced above the installation is complete.'
sleep 1
echo 'Be sure to add kernel parameters to grub, that part has not been completed.
sleep 1
echo 'Also It would be wise to verify SSH and configure your virtual machines before restarting to no display...'
