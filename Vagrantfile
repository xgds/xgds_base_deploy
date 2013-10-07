# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "canonical_ubuntu_precise64"
  config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box"

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
