bridge-utils:
  pkg.installed: []


kvm_packages:
  pkg.installed:
    - pkgs:
      - qemu-kvm
      {% if grains['os'] == 'Debian' %}
      - libvirt-daemon-system  # These two replace libvirt-bin
      - libvirt-clients
      {% endif %}
      {% if grains['os'] == 'Ubuntu' %}
      - libvirt-bin
      {% endif %}
      - gnutls-bin  # TLS connections to hypervisor
    - refresh: True


kvm_group:
  group.present:
    - name: kvm
    - addusers:
      - {{pillar['admin_user']}}


{% if grains['os'] == 'Debian' %}
qemu_group:
  group.present:
    - name: libvirt-qemu
    - addusers:
      - {{pillar['admin_user']}}


libvirt_group:
  group.present:
    - name: libvirt
    - addusers:
      - {{pillar['admin_user']}}
{% endif %}


{% if grains['os'] == 'Ubuntu' %}
libvirtd_group:
  group.present:
    - name: libvirtd
    - addusers:
      - {{pillar['admin_user']}}
{% endif %}


# TODO: figure out how to run QEMU without root user.
# Gives permission error when nobody:kvm. Difficult to locate source.
qemu_startup_user:
  file.replace:
    - name: /etc/libvirt/qemu.conf
    - pattern: "^#?user = \".*\""
    - repl: 'user = "root"'
    - append_if_not_found: True


qemu_startup_group:
  file.replace:
    - name: /etc/libvirt/qemu.conf
    - pattern: "^#?group = \".*\""
    {% if grains['os'] == 'Debian' %}
    - repl: 'group = "kvm"'
    {% endif %}
    {% if grains['os'] == 'Ubuntu' %}
    - repl: 'group = "libvirtd"'
    {% endif %}
    - append_if_not_found: True


salt_images_directory:
  file.directory:
    - name: /srv/salt-images
    - user: root
    {% if grains['os'] == 'Debian' %}
    - group: kvm
    {% endif %}
    {% if grains['os'] == 'Ubuntu' %}
    - group: libvirtd
    {% endif %}
    - dir_mode: 770
    - file_mode: 660
    - recurse:
      - user
      - group
      - mode


# https://docs.saltstack.com/en/latest/topics/tutorials/cloud_controller.html#cloud-controller
# For advanced features install libguestfs or qemu-nbd.
# Libguestfs and qemu-nbd allow for virtual machine images to be mounted before startup
# and get pre-seeded with configurations and a salt minion
kvm_packages_advanced:
  pkg.installed:
    - pkgs:
      - libguestfs0
      - libguestfs-tools
      - qemu-utils  # Contains qemu-nbd (Network Block Device)
      - libvirt-dev
      - python-libvirt
  service.running:
    - name: libvirt-guests
    - enable: True
    - reload: True


libvirt_keys:
  virt.keys


update_libvirt_python:
  pip.installed:
    - name: libvirt-python
    - bin_env: /usr/bin/pip2
    - upgrade: True


# TODO: only reload service on change.
libvirt_service:
  file.managed:
    - name: /etc/default/libvirtd
    - contents:
      - 'start_libvirtd="yes"'
      - 'libvirtd_opts="--listen"'
  service.running:
    - name: libvirtd
    - enable: True
    - reload: True
