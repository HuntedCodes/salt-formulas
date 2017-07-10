#!/usr/bin/env python

from __future__ import print_function

import os
import subprocess
import sys

xml_data = """
    <interface type='direct'>"
      <source dev='{0}' mode='bridge'/>
      <model type='rtl8139'/>
    </interface>"""

try:
    vm_name = os.environ['LIBVIRT_IMPORT_VM_NAME']
    vm_os = os.environ['LIBVIRT_IMPORT_OS']
    vm_distro = os.environ['LIBVIRT_IMPORT_DISTRO']
    vm_cpu = os.environ['LIBVIRT_IMPORT_CPU']
    vm_mem = os.environ['LIBVIRT_IMPORT_MEM']
    vm_disk_path = os.environ['LIBVIRT_IMPORT_DISK_PATH']
    vm_vnet = os.environ['LIBVIRT_IMPORT_VNET']
    vm_bridge = os.environ['LIBVIRT_IMPORT_BRIDGE']
    vm_direct_nic = os.environ['LIBVIRT_IMPORT_DIRECT_NIC']


    print('[*] Importing qcow2 disk image to KVM')
    print('[*]    VM Name:  {0}'.format(vm_name))
    print('[*]    OS:       {0}'.format(vm_os))
    print('[*]    Distro:   {0}'.format(vm_distro))
    print('[*]    CPU:      {0}'.format(vm_cpu))
    print('[*]    MEM:      {0}'.format(vm_mem))
    print('[*]    Disk:     {0}'.format(vm_disk_path))

    if not os.path.isfile(vm_disk_path):
        msg = '[!] Disk image not found: {0}'.format(vm_disk_path)
        print(msg, file=sys.stderr)
        raise ValueError(msg)

    nic_model = "rtl8139"
    vnet_arg = []
    if vm_vnet:
        for vnet in vm_vnet.split(','):
            print('[*]    VNet:     {0}'.format(vnet))
            vnet_arg.append('--network')
            vnet_arg.append('network={0},model={1}'.format(vnet, nic_model))
    bridge_arg = []
    if vm_bridge:
        for bridge in vm_bridge.split(','):
            print('[*]    Bridge:   {0}'.format(bridge))
            bridge_arg.append('--network')
            bridge_arg.append('bridge={0},model={1}'.format(bridge, nic_model))
    direct_nic_arg = []
    if vm_direct_nic:
        for direct_nic in vm_direct_nic.split(','):
            print('[*]    NIC:      {0}'.format(direct_nic))
            direct_nic_arg.append(direct_nic)

    if vnet_arg or bridge_arg:
        network_arg = vnet_arg + bridge_arg
    else:
        network_arg = ['--nonetworks']

    result = None
    print('[*] Creating the VM.')
    result = subprocess.check_output(
        [
            '/usr/bin/virt-install',
            '--connect', 'qemu:///system',
            '--name', vm_name,
            '--os-type', vm_os,
            '--os-variant', vm_distro,
            '--vcpus', vm_cpu,
            '--memory', vm_mem,
            '--disk', 'path={0},device=disk,format=qcow2'.format(vm_disk_path),
            '--import',
            '--video', 'qxl',
            '--channel', 'spicevmc',
            '--noautoconsole',
            '--noreboot',
            '--autostart',
        ] + network_arg
    )
    print('[*] Successfully created the VM.')

except Exception as e:
    print('[!] Failed to create the VM.')
    print(e)
    sys.exit(1)

try:
    for nic in direct_nic_arg:
        print('[*] Adding the direct NIC device {0}.'.format(nic))
        xml_path = '/tmp/directnic-{0}-{1}.xml'.format(vm_name, nic)
        xml_file = open(xml_path, 'w')
        xml_file.write(xml_data.format(nic))
        xml_file.close()

        nic_result = subprocess.check_output(
            [
                '/usr/bin/virsh',
                '--connect', 'qemu:///system',
                'attach-device',
                vm_name,
                xml_path,
                '--config',
            ]
        )
        print('[*] Successfully added direct NIC {0}.'.format(nic))

except Exception as e:
    print('[!] Failed to add direct NIC.')
    print(e)
    sys.exit(1)
