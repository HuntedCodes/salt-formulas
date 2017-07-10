Installation
============

Salt can be installed from pip as the `salt` package. Upgrade salt to the latest version
before running these formulas.


Commands
========

Master/Minion
-------------

Apply all specified states. Must run as root.

::

  sudo salt '*' state.apply


Refresh pillar data.

::

  sudo salt '*' saltutil.refresh_pillar

List pillar data.

::

  sudo salt '*' pillar.items

List grains data.

::

  sudo salt '*' grains.ls

Show individual grain.

::

  sudo salt '*' grains.get os


Masterless
----------

Create the salt state directory

::

  sudo mkdir -p /srv/salt

Call a specific salt state

::

  sudo salt-call --local state.sls tmux

Call the `top.sls` state file

::

  sudo salt-call --local state.highstate


Top Level Directory
===================

Example top.sls file
--------------------

The top state file defines which states are applied to which hosts.
It resides at the base file root, as defined in /etc/salt/master.

::

  base:  # Default environment (file root)
    '*':  # Apply these states to all machines.
      - namespace.formula
      - cli.git
    'host1':  # Apply these states to host1.
      - system.wifi
    'host2':  # Apply these states to host2.
      - system.nginx


State Formula 
=============

README.rst
----------

This file explains what the formula does and how to use it.
It must include the following pieces of information:

- Name
- Available states, with subheadings and descriptions.
- Formula dependencies
- Compatible platforms


init.sls
--------

This file contains all initial states for the formula, 
and references other sub-state files within the formula.
The formula takes the name of the parent folder.

Here is a basic *init.sls* file for installing a single package, which makes
use of a map.jinja file.

::

  {% from "wipe/map.jinja" import wipe with context %}
  
  wipe:
    pkg.installed:
      - name: {{ wipe.package }}


map.jinja
---------

This file contains OS specific values that are referenced from state files.
Values are defined conditionally, depending on the *os_family* grain.
The *salt['grains.filter_by']* function searches on the *os_family* grain by
default.

Here is an example of a simple map.jinja file for the *wipe* package.
It sets the default package name, and also the package name for Debian.

::

  {% set wipe = salt['grains.filter_by']({
    'default': {
      'package': 'wipe',
    },
    'Debian': {
      'package': 'wipe',
    },
  }, merge=salt['pillar.get']('wipe:lookup')) %}


Values can be mapped for a host according to any grain. Here is an example of filtering by the OS codename (i.e. "trusty," "xenial," or "jessie").

::

  {% set zendserver = salt['grains.filter_by']({
  	'trusty': {'version': { 'apache': '2.4' }},
  	'default': {'version': { 'apache': '2.2' }},
  }, 
  grain='oscodename', 
  merge=salt['pillar.get']('zendserver:lookup')) %}


files/
------

This directory contains any files needed by state files, 
including configuration templates. Files can be jinja templates.

pillar.example
--------------

This file shows how to define pillar data for the formula.



Pillar Files
============


Custom Grains
=============


References
==========

Best Practices
--------------

- `Salt Stack Best Practices <https://docs.saltstack.com/en/latest/topics/best_practices.html>`_
- `Repository Structure <https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html#repository-structure>`_
- `README.rst Structure <https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html#readme-rst>`_
- `Salt Stack Abstracting Static Defaults <https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html#abstracting-static-defaults-into-a-lookup-table>`_

Docs
----

- `Jinja Template Docs <http://jinja.pocoo.org/docs/dev/templates/>`

3rd Party Formulas
------------------

- `github.com/saltstack-formulas <https://github.com/search?q=org%3Asaltstack-formulas&ref=searchresults&type=Repositories&utf8=%E2%9C%93>`_
