import os
import logging

from salt.exceptions import CommandExecutionError, SaltInvocationError


log = logging.getLogger(__name__)


def target_vm_mac(vm_name, config):
    if vm_name is None:
        raise SaltInvocationError('vm_name was not specified.')

    if config is None:
        raise SaltInvocationError('config file was not specified.')

    if not os.path.isfile(config):
        raise CommandExecutionError(
            'Failed to find SYSLINUX configuration file {0}'.format(config)
        )

    try:
        macs = __salt__['virt.get_macs'](vm_name)
    except Exception:
        raise CommandExecutionError(
            'Failed to find MAC addresses for VM domain {0}'.format(vm_name)
        )

    results = {}
    for mac in macs:
        mac = mac.replace(':', '-')
        dst_filename = '01-{0}'.format(mac)
        (config_dir, config_filename) = os.path.split(config)
        linkpath = os.path.join(config_dir, dst_filename)

        # Skip valid link, or remove invalid link.
        if os.path.islink(linkpath):
            if os.readlink(linkpath) == config_filename:
                results[linkpath] = False
                continue
            os.remove(linkpath)

        # Symlink must be relative to be served.
        os.symlink(
            os.path.relpath(config, config_dir),
            linkpath
        )

        log.debug('Created syslinux symlink {0} for vm {0}'.format(
            linkpath, vm_name
        ))
        results[linkpath] = True

    return results
