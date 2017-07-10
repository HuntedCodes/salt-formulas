# https://pve.proxmox.com/wiki/Package_repositories
# https://pve.proxmox.com/wiki/Install_Proxmox_VE_on_Debian_Stretch
proxmox_network:
  file.managed:
    - name: /etc/hosts
    - source: salt://proxmox/hosts.jinja
    - template: jinja


proxmox_repo:
  pkgrepo.managed:
   - humanname: Official Proxmox Repository
   - file: /etc/apt/sources.list.d/proxmox.list
   {% if grains['lsb_distrib_codename'] == 'jessie' %}
   - name: deb http://download.proxmox.com/debian jessie pve-no-subscription
   - key_url: salt://proxmox/proxmox-ve-release-4.x.gpg
   {% else %}
   - name: deb http://download.proxmox.com/debian/pve {{ grains.lsb_distrib_codename }} pvetest
   - key_url: salt://proxmox/proxmox-ve-release-5.x.gpg
   {% endif %}
   - refresh_db: True


#proxmox_pkgs:
#  pkg.installed:
#    - proxmox-ve
#    - postfix
#    - open-iscsi
#  pkg.removed:
#    - os-prober
