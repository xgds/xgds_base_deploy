
# xgds_base_vagrant

This package builds an xgds_base vagrant VM suitable to use for sites
developed as part of the xGDS project. The VM contains pre-installed
versions of our commonly used packages and can be used as a starting
point for installing site-specific items.

The intent is that 'admin' team members are responsible for creating and
maintaining a team-wide copy of the xgds_base VM in a well-known
location on a common server. Most team members just use the team-wide
copy.

## Using an xgds_base VM

Most users won't need to build a base VM but only need to use
it by pointing to it from a site-specific Vagrantfile:

    vagrant.vm.box_url = "... figure out ssh syntax ..."

## Building an xgds_base VM

You will need up-to-date copies of Vagrant (1.1+) and VirtualBox
(4.2.10).

Procedure:

    vagrant up

Now install the VirtualBox guest additions in the VM:

    VBoxManage list vms
    VM=xgds_base_vagrant_default_1382128593 # pick the VM you want from the list

    find /Applications/VirtualBox.app -name "*.iso"  # locate guest additions iso
    ISO=/Applications/VirtualBox.app/Contents/MacOS/VBoxGuestAdditions.iso  # your path may vary

    VBoxManage storageattach $VM --storagectl "SATAController" --port 1 --device 0 --type dvddrive --medium $ISO

    vagrant ssh
    sudo -i
    mount /dev/cdrom /mnt
    /mnt/VBoxLinuxAdditions.run
    exit
    exit

    vagrant reload

Next, optionally resize the virtual disk to allow more data to be stored
as needed. Ubuntu cloud images start at 40 GB and currently we resize to
400 GB:

    vagrant halt
    cd "~/VirtualBox VMs/"
    VM=xgds_base_vagrant_default_1382128593  # choose the VM you're working on
    cd $VM
    # detach disk from VM before working with it
    VBoxManage storageattach $VM --storagectl "SATAController" --port 0 --device 0 --medium none
    VBoxManage closemedium disk box-disk1.vmdk
    # note: vbox currently can't resize vmdk format, so we have some 'clonehd' format conversions
    mv box-disk1.vmdk old.vmdk
    VBoxManage clonehd old.vmdk new.vdi --format vdi
    VBoxManage modifyhd new.vdi --resize 400000
    VBoxManage clonehd new.vdi box-disk1.vmdk --format vmdk
    # reattach disk to VM when done
    VBoxManage storageattach $VM --storagectl "SATAController" --port 0 --device 0 --type hdd --medium box-disk1.vmdk

Next:
    vagrant provision
    vagrant package --output xgds_base.box
    rsync -av --partial --inplace --progress xgds_base.box irg@pll.xgds.org:/home/irg/boxes/xgds_base.box.part
    ssh irg@pll.xgds.org mv -f boxes/xgds_base.box.part boxes/xgds_base.box
