## Locations

- Domain XML specifications are stored at /etc/libvirt/qemu/.

## Modifications

### Disk profiles

- Support "old location" for disk profiles, like nic profiles.


### QEMU/KVM specific

If hypervisor is kvm or qemu.

- Create qcow2 images for disk profiles with module `qemu_img.make_image`
- Use `if salt.utils.which('qemu-img'):` to ensure exe exists.
- Use the config.option `virt.images` for image destination.
  Defaults to '/srv/salt-images'.
- slot/bus
  - It looks like KVM automatically adds necessary attributes.
  - Add incrementing 'slot' attribute to devices, for XML template.
- Add option for spice instead of VNC. Default to false.


### Devices

- Allow optional input (keyboard/mouse).
- Allow optional memory balloon, default to false.
- Allow only specified disks and NICs to be booted from: <boot order='1'>.
- Document how to pass boot order kwargs, with example.
- USB device support. USB profiles?


### Network Profiles

- Add VLAN support to network profiles.
