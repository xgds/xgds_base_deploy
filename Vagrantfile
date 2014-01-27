# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("1") do |config|
  # run "VAGRANT_GUI=1 vagrant up" to get a display; default is headless mode
  if ENV['VAGRANT_GUI'] != nil
    config.vm.boot_mode = :gui
  end
end

Vagrant.configure("2") do |config|
  # 64-bit Ubuntu VMs fail under VirtualBox 4.2 in Mac OS X 10.6 (hang
  # on startup).  As we upgrade our dev machines, at some point we may
  # be able to switch to 64-bit.
  config.vm.box = "canonical_ubuntu_precise32"
  config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-i386-vagrant-disk1.box"

  # Assign this VM to a host-only network IP, allowing you to access it
  # via the IP. Host-only networks can talk to the host machine as well as
  # any other machines on the same network, but cannot be accessed (through this
  # network interface) by any external networks.
  config.vm.network "private_network", ip: "10.0.3.11"

  # use shell script to install latest puppet before using puppet
  $puppet_update_script = <<EOF
[ -f puppetlabs-release-precise.deb ] || wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb
dpkg-query -l puppetlabs-release-precise && sudo dpkg -i puppetlabs-release-precise.deb
[ -f .puppet-apt-updated ] || sudo apt-get update && touch .puppet-apt-updated
[ -f .puppet-upgraded ] || sudo apt-get install --yes --upgrade puppet
EOF
  config.vm.provision :shell, :inline => $puppet_update_script

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "puppet/manifests"
    puppet.module_path = "puppet/modules"
    puppet.manifest_file  = "base.pp"
    puppet.options = "--debug --verbose"
  end
end
