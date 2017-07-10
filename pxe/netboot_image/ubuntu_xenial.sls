# TODO: Bug where SaltStack can't delete directory symlinks in this state.
# Fixed in latest release, I think.
ubuntu_xenial_netboot_image:
  archive.extracted:
    - name: /srv/docker/pxe/dnsmasq/tftp/ubuntu/xenial
    - source: http://archive.ubuntu.com/ubuntu/dists/xenial-updates/main/installer-amd64/current/images/netboot/netboot.tar.gz
    - source_hash: 053ae34e48899d043ea79df80d9101e0bc5aa996be60261b5bf90cc5b5777939
    - keep: True
    - enforce_toplevel: False
    - user: root
    - group: docker
    - if_missing: /srv/docker/pxe/dnsmasq/tftp/ubuntu/xenial/ubuntu-installer/amd64/linux
