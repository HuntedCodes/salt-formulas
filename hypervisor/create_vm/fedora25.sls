# Logs are in /var/log/libvirt/qemu
fedora25_vm:
  module.run:
    - name: virt.init
    - m_name: fedora2
    - cpu: 2
    - mem: 512
    - image: salt://Fedora-Atomic-25-20170314.0.x86_64.qcow2
    - nic: default
