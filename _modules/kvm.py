'''
Create virtual machines for the KVM hypervisor.

Parameters:

- name
- cpu
- mem
- disk
- nic
- start

Generated:

- uuid
- mac
- arch
- boot_order: disk, nic
- image path, /srv/salt-images/<name>/
- image, system.qcow2
- graphics
- memballoon
- input

:depends: libvirt Python module
'''

import os
import string  # pylint: disable=deprecated-module
import uuid


def _gen_kvm_header_xml(name):
    header_xml = """<domain type='kvm'>
  <name>%s</name>
  <uuid>%s</uuid>
  <os>
    <type arch='x86_64' machine='pc-i440fx-2.8'>hvm</type>
  </os>
  <features>
    <acpi/>
  </features>
  <clock offset='utc'/>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>destroy</on_crash> \n""" % (name, uuid.uuid4())
    return header_xml


def _gen_kvm_system_xml(cpu, mem_size):
    system_xml = """  <vcpu placement='static'>%s</vcpu>
  <memory unit='MiB'>%s</memory>
  <currentMemory unit='MiB'>%s</currentMemory>
  <memballoon model='virtio'>
    <address type='pci' domain='0x0000' bus='0x00' slot='0x04' function='0x0'/>
  </memballoon>\n""" % (cpu, mem_size, mem_size)
    return system_xml


def _gen_kvm_device_header_xml():
    kvm_path = which('kvm')
    header_xml =  """  <devices>
    <emulator>%s</emulator>\n""" % kvm_path
    return header_xml


def _gen_kvm_disk_xml(disk_path):
    disk_xml = """    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2' cache='none' io='native'/>
      <source file='%s'/>
      <target dev='vda' bus='virtio'/>
      <boot order='1'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>
    </disk>\n""" % disk_path

    return disk_xml


def _gen_kvm_controller_xml():
    controller_xml = """    <controller type='usb' index='0' model='piix3-uhci'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x2'/>
    </controller>
    <controller type='pci' index='0' model='pci-root'/>\n"""

    return controller_xml


def _gen_kvm_input_xml():
    input_xml = """    <input type='mouse' bus='ps2'/>
    <input type='keyboard' bus='ps2'/>\n"""

    return input_xml


def _gen_kvm_display_xml():
    display_xml = """    <graphics type='spice' autoport='yes'>
      <listen type='address'/>
    </graphics>
    <video>
      <model type='cirrus' vram='16384' heads='1' primary='yes'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x05' function='0x0'/>
    </video>\n"""

    return display_xml


def _gen_kvm_device_footer_xml():
    return '  </devices>\n'


def _gen_kvm_footer_xml():
    return '</domain>'


def init(name,
         cpu=1,
         mem_size=512,
         disk_size=4096,
         nic='default',
         start=True,
         saltenv='base',
         **kwargs):
    '''
    Initialize a new vm

    CLI Example:

    .. code-block:: bash

        salt 'hypervisor' kvm.init vm_name 1 512 8192 profile
    '''
    name = name.replace(string.whitespace, '-').replace(string.punctuation, '')

    # Disk paths
    disk_base = '/srv/salt-images/%s' % name
    disk_name = 'system.qcow2'
    disk_path = '%s/%s' % (disk_base, disk_name)

    # Ensure path
    if not os.path.exists(disk_base):
        os.makedirs(disk_base)

    # Create disk
    result = __salt__['qemu_img.make_image'](
        '/srv/salt-images/%s/system.qcow2' % name,
        disk_size,
        'qcow2'
    )

    # Generate domain XML
    xml_file = open('%s/vm.xml' % disk_base, 'w')

    xml_file.write(_gen_kvm_header_xml(name))
    xml_file.write(_gen_kvm_system_xml(cpu, mem_size))
    xml_file.write(_gen_kvm_device_header_xml())
    xml_file.write(_gen_kvm_controller_xml())
    xml_file.write(_gen_kvm_disk_xml(disk_path))
    xml_file.write(_gen_kvm_input_xml())
    xml_file.write(_gen_kvm_display_xml())
    xml_file.write(_gen_kvm_device_footer_xml())
    xml_file.write(_gen_kvm_footer_xml())

    xml_file.close()

    return True


def which(program):
    import os
    def is_exe(fpath):
        return os.path.isfile(fpath) and os.access(fpath, os.X_OK)

    fpath, fname = os.path.split(program)
    if fpath:
        if is_exe(program):
            return program
    else:
        for path in os.environ["PATH"].split(os.pathsep):
            path = path.strip('"')
            exe_file = os.path.join(path, program)
            if is_exe(exe_file):
                return exe_file

    return None
