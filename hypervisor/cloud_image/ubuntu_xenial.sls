# https://cloud-images.ubuntu.com/xenial/
ubuntu_xenial_image:
  file.managed:
    - name: /srv/salt/xenial-server-cloudimg-amd64-disk1.img
    - source: http://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img
    - source_hash: 7c53f8b1623cef3392ce3903de47a21a74fe4e25b5194dcc6dae9e7a5194740b
