extract_packer:
  archive.extracted:
    - name: /tmp/packer-1.0.0
    - source: https://releases.hashicorp.com/packer/1.0.0/packer_1.0.0_linux_amd64.zip
    - source_hash: ed697ace39f8bb7bf6ccd78e21b2075f53c0f23cdfb5276c380a053a7b906853
    - enforce_toplevel: False

copy_packer_binary:
  file.managed:
    - name: /usr/local/bin/packer
    - source: /tmp/packer-1.0.0/packer
    - user: root
    - group: root
    - mode: '0755'
    - unless: sha256sum /usr/local/bin/packer | grep 582f228c271b1ada13a067e61b6101aaaffacc3bebb29589273e9e9de4cf72c2
