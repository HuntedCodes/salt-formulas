python2_packages:
  pkg.installed:
    - pkgs:
      - python
      - python-dev
      - python-pip

update_pip2:
  pip.installed:
    - name: pip
    - bin_env: /usr/bin/pip2
    - upgrade: True
