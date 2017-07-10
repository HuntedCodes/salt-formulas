debian_jessie_vm:
  module.run:
    - name: virt.init
    - m_name: debian-jessie1
    - cpu: 2
    - mem: 512
    - image: salt://debian-8.7.3-20170323-openstack-amd64.qcow2
    - nic: default
