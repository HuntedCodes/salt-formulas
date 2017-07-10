# https://alt.fedoraproject.org/cloud/
fedora_atomic25_image:
  file.managed:
    - name: /srv/salt/Fedora-Atomic-25-20170314.0.x86_64.qcow2
    - source: https://download.fedoraproject.org/pub/alt/atomic/stable/Fedora-Atomic-25-20170314.0/CloudImages/x86_64/images/Fedora-Atomic-25-20170314.0.x86_64.qcow2
    - source_hash: da64200d46c176aed4c6d046106fa6e6c4bf2fe06dcd64f07310ed8ae07c51a7
