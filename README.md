
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

Now install the VirtualBox guest additions in the VM. This
is a somewhat painful manual process.

Next:
    vagrant provision
    vagrant package --output xgds_base.box
    rsync -av --partial --inplace --progress xgds_base.box irg@pll.xgds.org:/home/irg/boxes/xgds_base.box.part
    ssh irg@pll.xgds.org mv -f boxes/xgds_base_box.part boxes/xgds_base.box
