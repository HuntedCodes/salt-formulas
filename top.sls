base:
  'obsidian':
    - chrome.install
    - sudo
    - firewall
    - apt
    - common
    - git
    - python
    - tmux
    - vim
    - wireshark
    - mdns.avahi
    - network.forward
    - network.interfaces
    - libvirt.install
    - libvirt.install_gui
    - libvirt.vnet
    - packer.install
    - packer.configure
    - cloud.libvirt.provider
    - cloud.libvirt.profiles
    - cloud.libvirt.build
    - cloud.libvirt.attach
  'onyx':
    # - sudo
    # - firewall
    # - mdns.avahi
    # - dlna.dleyna
    # - apt
    # - python
    # - tmux
    # - systemd.logind
    # - ssh.user_key
    # - openvpn.network_manager.all_wifi
    # - network.forward
    # - network.mac_random
    # - libvirt.install
    # - libvirt.install_gui
    # - libvirt.vnet
    # - packer.install
    - packer.configure
    # - packer.build
    # - cloud.libvirt.import
    # - cloud.libvirt.provider
    # - cloud.libvirt.profiles
    # - cloud.libvirt.create
  'docker5.service.lan':
    - sudo
    - apt
    - python
    - tmux
    - mdns.avahi
    - network.forward
    - docker.install
    - docker.compose_install
    - docker.swarm
  'unused_tests':
    - hypervisor.network
    - hypervisor.create_vm.test
    - docker.install
    - pxe.install
    - pxe.netboot_image
    - proxmox.install
  'unassigned':
    - git
    - vim
    - c
    - ruby
    - java
    - binary_analysis
    - network_analysis
