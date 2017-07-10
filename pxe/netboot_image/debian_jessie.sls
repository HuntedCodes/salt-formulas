# TODO: Bug where SaltStack can't delete directory symlinks in this state.
# Fixed in latest release, I think.
debian_jessie_netboot_image:
  archive.extracted:
    - name: /srv/docker/pxe/dnsmasq/tftp/debian/jessie
    - source: http://ftp.us.debian.org/debian/dists/jessie/main/installer-amd64/current/images/netboot/netboot.tar.gz
    - source_hash: 9b4bb9e537cb2b9c8da4c9b108ceb22b686bce8846116d9f255373d6ed3dde07
    - keep: True
    - enforce_toplevel: False
    - user: root
    - group: docker
    - if_missing: /srv/docker/pxe/dnsmasq/tftp/debian/jessie/debian-installer/amd64/linux
