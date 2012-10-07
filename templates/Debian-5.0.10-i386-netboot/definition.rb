Veewee::Definition.declare({
  :cpu_count => '1',
  :memory_size=> '256',
  :disk_size => '10140', :disk_format => 'VDI', :hostiocache => 'off',
  :os_type_id => 'Debian_64',
  :iso_file => "debian-5010-i386-netinst.iso",
  :iso_src => "http://cdimage.debian.org/cdimage/archive/5.0.10/i386/iso-cd/debian-5010-i386-netinst.iso",
  :iso_md5 => "b696d8c87bb428c21a22a95cd49b75c2",
  :iso_download_timeout => "1000",
  :boot_wait => "10", :boot_cmd_sequence => [
    '<Esc>',
    'install ',
    'preseed/url=http://%IP%:%PORT%/preseed.cfg ',
    'debian-installer=en_US ',
    'auto ',
    'locale=en_US ',
    'kbd-chooser/method=us ',
    'netcfg/get_hostname=%NAME% ',
    'netcfg/get_domain=vagrantup.com ',
    'fb=false ',
    'debconf/frontend=noninteractive ',
    'console-setup/ask_detect=false ',
    'console-keymaps-at/keymap=us ',
    '<Enter>'
  ],
  :kickstart_port => "7122",
  :kickstart_timeout => "10000",
  :kickstart_file => "preseed.cfg",
  :ssh_login_timeout => "10000",
  :ssh_user => "vagrant",
  :ssh_password => "vagrant",
  :ssh_key => "",
  :ssh_host_port => "7222",
  :ssh_guest_port => "22",
  :sudo_cmd => "echo '%p'|sudo -S sh '%f'",
  :shutdown_cmd => "halt -p",
  :postinstall_files => [ "postinstall.sh" ],
  :postinstall_timeout => "10000"
})
