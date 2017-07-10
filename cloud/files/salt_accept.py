#!/usr/bin/env python

from __future__ import print_function

import os
import subprocess
import sys
import time

timeout_sec = 60*2  # Seconds

try:
    vm_name = os.environ['LIBVIRT_VM_NAME']
    vm_domain = os.environ['LIBVIRT_DOMAIN']

    key_name = vm_name
    if vm_domain:
        key_name += '.{0}'.format(vm_domain)

    # Check if key already accepted.
    result = subprocess.check_output(
        ['/usr/bin/salt-key', '-l', 'accepted']
    )
    result = result.split('\n')
    if key_name in result:
        msg = '[*] Minion key for {0} is already accepted'
        print(msg.format(key_name))
        sys.exit(0)

    # Wait for key, then accept.
    msg = '[*] Waiting {0} seconds for salt key: {1}'
    print(msg.format(timeout_sec, key_name))

    timeout = time.time() + timeout_sec
    while True:
        # Check for unaccepted key.
        result = subprocess.check_output(
            ['/usr/bin/salt-key', '-l' 'unaccepted']
        )
        result = result.split('\n')

        if key_name in result:
            add_result = subprocess.check_output(
                ['/usr/bin/salt-key', '-ya', key_name]
            )
            msg = '[*] Accepted salt minion key for {0}'
            print(msg.format(key_name))
            sys.exit(0)

        if time.time() > timeout:
            break

    msg = '[!] Time has expired waiting for {0} minion key'
    print(msg.format(key_name))
    sys.exit(1)

except Exception as e:
    print('[!] Failed to accept the salt minion key.')
    print(e)
    sys.exit(1)
