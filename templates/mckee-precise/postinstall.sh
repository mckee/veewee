
#filesystem tweaks
tune2fs -c0 -i0 -m0 /dev/os/root

date > /etc/vagrant_box_build_time

# package modifications
cat > /etc/apt/sources.list.d/puppetlabs.list <<EOF
deb http://apt.puppetlabs.com/ precise main 
EOF
wget http://apt.puppetlabs.com/pubkey.gpg -O - | sudo apt-key add -
apt-get -y update
apt-get -y install linux-headers-$(uname -r) build-essential zlib1g-dev libssl-dev libreadline-gplv2-dev vim puppet dkms nfs-common rubygems curl vim-nox

# Installing the virtualbox guest additions
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt
rm VBoxGuestAdditions_$VBOX_VERSION.iso

# Full upgrade, but don't use the packaged guest additions as they are old.
echo virtualbox-guest-dkms hold | dpkg --set-selections
apt-get -y dist-upgrade

# install the guest additions kernel modules
NEW_KERNEL=$(ls /boot/vmlinuz* | tail -1 | sed 's/.*vmlinuz-//')
dkms autoinstall $NEW_KERNEL
INSTALL_KERNEL=$(uname -r)
apt-get -y purge linux-image-${INSTALL_KERNEL} linux-headers-${INSTALL_KERNEL}
update-initramfs -ck all
update-grub2
apt-get clean

# Chef
gem install chef --no-rdoc --no-ri 

# Setup sudo to allow no-password sudo for "admin"
groupadd -r admin
usermod -a -G admin vagrant
cp /etc/sudoers /etc/sudoers.orig
sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=admin' /etc/sudoers
sed -i -e 's/%admin ALL=(ALL) ALL/%admin ALL=NOPASSWD:ALL/g' /etc/sudoers

# Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh

# Zero out the free space to save space in the final image:
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# Removing leftover leases and persistent rules
echo "cleaning up dhcp leases"
rm /var/lib/dhcp/*

# Make sure Udev doesn't block our network
# http://6.ptmc.org/?p=164
echo "cleaning up udev rules"
rm /etc/udev/rules.d/70-persistent-net.rules
mkdir /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm /lib/udev/rules.d/75-persistent-net-generator.rules

echo "Adding a 2 sec delay to the interface up, to make the dhclient happy"
echo "pre-up sleep 2" >> /etc/network/interfaces
exit
