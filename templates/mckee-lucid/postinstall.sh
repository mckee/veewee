#filesystem tweaks
tune2fs -c0 -i0 -m0 /dev/os/root

#Updating the box
apt-get -y update
apt-get -y dist-upgrade
apt-get -y install linux-headers-$(uname -r) build-essential openssh-server ruby ruby-dev libopenssl-ruby1.8 irb ri rdoc nfs-common nfs-client dkms curl vim-nox
apt-get clean

#Set a sane default editor
update-alternatives --set editor /usr/bin/vim.nox

#Setting up sudo
cp /etc/sudoers /etc/sudoers.orig
sed -i -e 's/%admin ALL=(ALL) ALL/%admin ALL=NOPASSWD:ALL/g' /etc/sudoers

#rubygems
wget http://production.cf.rubygems.org/rubygems/rubygems-1.7.2.tgz
tar xvf rubygems-1.7.2.tgz
cd rubygems-1.7.2
ruby setup.rb --no-rdoc --no-ri --no-format-executable
cd 
rm -rf rubygems*

#Installing chef & Puppet
gem install puppet chef --no-ri --no-rdoc

#Hostname
hostname=`facter lsbdistcodename`
hostname $hostname
echo $hostname > /etc/hostname
cat << _HOSTS_ > /etc/hosts
127.0.0.1 localhost
127.0.1.1 $hostname.lab.tibre.org $hostname
_HOSTS_

#Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'http://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub' -O authorized_keys
chown -R vagrant /home/vagrant/.ssh

#Installing the virtualbox guest additions
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
cd /tmp
wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt

apt-get -y remove linux-headers-$(uname -r) build-essential
apt-get -y autoremove

rm VBoxGuestAdditions_$VBOX_VERSION.iso
rm /home/vagrant/postinstall.sh

dd if=/dev/zero of=Z
rm Z

exit
