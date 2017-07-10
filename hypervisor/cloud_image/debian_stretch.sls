# These images are intende for use with OpenStack.
# http://cdimage.debian.org/cdimage/openstack/
# http://thomas.goirand.fr/blog/?p=237
debian_stretch_image:
  file.managed:
    - name: /srv/salt/debian-testing-openstack-amd64.qcow2
    - source: http://cdimage.debian.org/cdimage/openstack/testing/debian-testing-openstack-amd64.qcow2
    - source_hash: 507b4d1ca791d97f490abd13ea490dc3ccbf50647cfb089153df391d1f82431f0d9f81050657b896dec3c6d0821c3791d176e495777e94d8eb0bab13ecc5ca05
