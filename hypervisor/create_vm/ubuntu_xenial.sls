# Logs are in /var/log/libvirt/qemu
ubuntu_vm:
  module.run:
    - name: virt.init
    - m_name: ubuntu7
    - cpu: 2
    - mem: 512
    - image: salt://xenial-server-cloudimg-amd64-disk1.img
    - nic: default
