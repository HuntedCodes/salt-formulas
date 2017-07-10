import os
import logging

from salt.exceptions import CommandExecutionError, SaltInvocationError


log = logging.getLogger(__name__)


def target_vm_mac(name, config):
    if name is None:
        raise SaltInvocationError('name was not specified.')

    if config is None:
        raise SaltInvocationError('config file was not specified.')

    ret = {
        'name': name,
        'changes': {},
        'result': False,
        'comment': '',
        'pchanges': {},
    }

    result = __salt__['syslinux.target_vm_mac'](name, config)
    if True in result.values():
        ret['changes'] = result
    else:
        ret['comment'] = 'No changes made'

    ret['result'] = True
    return ret
