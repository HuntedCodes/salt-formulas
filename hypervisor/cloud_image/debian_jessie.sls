# These images are intende for use with OpenStack.
# http://cdimage.debian.org/cdimage/openstack/
# http://thomas.goirand.fr/blog/?p=237
debian_jessie_image:
  file.managed:
    - name: /srv/salt/debian-8.7.3-20170323-openstack-amd64.qcow2
    - source: http://cdimage.debian.org/cdimage/openstack/current/debian-8.7.3-20170323-openstack-amd64.qcow2
    - source_hash: bec3cea65507a5c2712259d396cc4f8b087ad734440e435a0274875a6c99d8dff5a51542d17d992709e809d2e63779d392202f87c3db011a3a6d022c69d69fc4
