'''
Salt state module for libvirt VMs.

Use:
  libvirtng.present:
      - name: myvm      # VM name.
      - cpu: 2          # System CPU cores.
      - mem: 1024       # System memory (MB).
      - network:        # Network interfaces.
        - default
        - management
      - bridge:         # Bridge interfaces.
        - br0
      - auto: True      # Automatically start the machine on boot.
      - force: True     # Reboot the machine.
'''
import os
import logging
import subprocess
import time

import libvirt

from salt.exceptions import CommandExecutionError, SaltInvocationError


log = logging.getLogger(__name__)


def __virtual__():
    return True


def _shutdown_domain(domain):
    if domain.isActive():
        count = 3
        while count > 0 and domain.isActive():
            domain.shutdown()
            time.sleep(3)
        if domain.isActive():
            domain.destroy()


def _reboot_domain(domain):
    if domain.isActive():
        _shutdown_domain(domain)
        domain.create()


def _set_cpu(vm_domain, cpu, force):
    current_cpu = vm_domain.info()[3]
    if cpu == current_cpu:
        return {}

    cmd = [
        'virsh', '--connect', 'qemu:///system',
        'setvcpus', vm_domain.name(), str(cpu),
        '--maximum', '--config'
    ]
    subprocess.check_output(cmd)
    del cmd[6]
    subprocess.check_output(cmd)
    return {'cpu': {'old': current_cpu, 'new': cpu}}


def _set_mem(vm_domain, mem, force):
    current_mem = vm_domain.info()[1]
    mem = mem * 1024
    if mem == current_mem:
        return {}

    cmd = [
        'virsh', '--connect', 'qemu:///system',
        'setmaxmem', vm_domain.name(), str(mem),
        '--config'
    ]
    subprocess.check_output(cmd)
    cmd[3] = 'setmem'
    subprocess.check_output(cmd)
    old = '{0} ({1})'.format(current_mem/1024, current_mem)
    new = '{0} ({1})'.format(mem/1024, mem)
    return {'memory': {'old': old, 'new': new}}


def _list_interfaces(vm_domain, net_type='network'):
    # Couldn't find an API that lists networks for *inactive* domains.
    # Using an external `virsh` command instead.
    # virsh --connect qemu:///system domiflist <domain>
    cmd = [
        'virsh', '--connect', 'qemu:///system',
        'domiflist', vm_domain.name()
    ]
    output = subprocess.check_output(cmd)
    output = output.split('\n')
    output = [x.split() for x in output if net_type in x]

    result = []
    for i in output:
       iface = {
           'type': i[1],
           'source': i[2],
           'model': i[3],
           'mac': i[4],
       }
       result.append(iface)

    return result


def _list_networks(vm_domain):
    return _list_interfaces(vm_domain, 'network')


def _list_bridges(vm_domain):
    return _list_interfaces(vm_domain, 'bridge')


def _has_network(vm_domain, network):
    net_list = _list_networks(vm_domain)
    if network in [x['source'] for x in net_list]:
        return True
    return False


def _has_bridge(vm_domain, bridge):
    br_list = _list_bridges(vm_domain)
    if bridge in [x['source'] for x in br_list]:
        return True
    return False


def _add_interface(vm_domain, net_type='network', source='default', force=False):
    # The libvirt API has no direct equivalent of the virsh `attach-interface`
    # command, so using virsh will do here for simplicity.
    cmd = [
        'virsh', '--connect', 'qemu:///system',
        'attach-interface', vm_domain.name(),
        net_type, source,
        '--model', 'rtl8139',
        '--config'
    ]
    output = subprocess.check_output(cmd)
    return output


def _add_network(vm_domain, network, force):
    if _has_network(vm_domain, network):
        return {}
    _add_interface(vm_domain, net_type='network', source=network, force=force)
    return {'network - {0}'.format(network): {'old': 'Absent', 'new': 'Present'}}


def _add_bridge(vm_domain, bridge, force):
    if _has_bridge(vm_domain, bridge):
        return {}
    _add_interface(vm_domain, net_type='bridge', source=bridge, force=force)
    return {'bridge - {0}'.format(bridge): {'old': 'Absent', 'new': 'Present'}}


def _remove_interface(vm_domain, net_type='network', source='default', force=False):
    interfaces = _list_interfaces(vm_domain, net_type)
    mac_list = [x['mac'] for x in interfaces if x['source'] == source]

    # The libvirt API has no direct equivalent of the virsh `detach-interface`
    # command, so using virsh will do here for simplicity.
    cmd = [
        'virsh', '--connect', 'qemu:///system',
        'detach-interface', vm_domain.name(),
        net_type,
        '--mac', 'placeholder',
        '--config'
    ]
    for mac in mac_list:
        cmd[7] = mac
        output = subprocess.check_output(cmd)
    return mac_list


def _remove_network(vm_domain, network, force):
    if not _has_network(vm_domain, network):
        return {}
    _remove_interface(vm_domain, net_type='network', source=network, force=force)
    return {'network - {0}'.format(network): {'old': 'Present', 'new': 'Absent'}}


def _remove_bridge(vm_domain, bridge, force):
    if not _has_bridge(vm_domain, bridge):
        return {}
    _remove_interface(vm_domain, net_type='bridge', source=bridge, force=force)
    return {'bridge - {0}'.format(bridge): {'old': 'Present', 'new': 'Absent'}}


def _set_network(vm_domain, network=None, force=False):
    if network:
        old_net_list = [x['source'] for x in _list_networks(vm_domain)]
        new_net_list = list(old_net_list)
        for n in new_net_list:
            if n not in network:
                _remove_network(vm_domain, n, force)
                new_net_list.remove(n)
        for n in network:
            if _add_network(vm_domain, n, force):
                new_net_list.append(n)
        if new_net_list != old_net_list:
            return {'network': {'old': old_net_list, 'new': new_net_list}}
    return {}


def _set_bridge(vm_domain, bridge=None, force=False):
    old_br_list = [x['source'] for x in _list_bridges(vm_domain)]
    if bridge:
        new_br_list = list(old_br_list)
        for n in new_br_list:
            if n not in bridge:
                _remove_bridge(vm_domain, n, force)
                new_br_list.remove(n)
        for n in bridge:
            if _add_bridge(vm_domain, n, force):
                new_br_list.append(n)
        if new_br_list != old_br_list:
            return {'bridge': {'old': old_br_list, 'new': new_br_list}}
    else:
        for n in old_br_list:
            _remove_bridge(vm_domain, n, force)
            return {'bridge': {'old': old_br_list, 'new': []}}

    return {}


def _set_auto(vm_domain, auto):
    if auto and not vm_domain.autostart():
        vm_domain.setAutostart(True)
        return {'autostart': {'old': False, 'new': True}}
    if not auto and vm_domain.autostart():
        vm_domain.setAutostart(False)
        return {'autostart': {'old': True, 'new': False}}
    return {}


def present(name,
            cpu=1,
            mem=512,
            network=['default'],
            bridge=None,
            auto=False,
            force=False):
    if name is None:
        raise SaltInvocationError('name was not specified.')

    ret = {
        'name': name,
        'changes': {},
        'result': False,
        'comment': '',
        'pchanges': {},
    }

    try:
        conn = libvirt.open('qemu:///system')
    except:
        msg = 'Cannot connect to local libvirt daemon.'
        log.error(msg)
        ret['comment'] = msg
        return ret

    try:
        vm_domain = conn.lookupByName(name)
    except:
        msg = 'VM domain {0} does not exist.'.format(name)
        log.error(msg)
        ret['comment'] = msg
        return ret

    active = vm_domain.isActive()

    ret['changes'].update(_set_cpu(vm_domain, cpu, force))
    ret['changes'].update(_set_mem(vm_domain, mem, force))
    ret['changes'].update(_set_network(vm_domain, network, force))
    ret['changes'].update(_set_bridge(vm_domain, bridge, force))
    ret['changes'].update(_set_auto(vm_domain, auto))

    if force and active and ret['changes']:
        _reboot_domain(vm_domain)
        change = {'force reboot': {'old': 'running', 'new': 'rebooted'}}
        ret['changes'].update(change)

    if not ret['changes']:
        ret['comment'] = 'No changes made'

    ret['result'] = True
    return ret
