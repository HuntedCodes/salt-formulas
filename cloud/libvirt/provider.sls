cloud_provider_libvirt:
  file.managed:
    - name: /etc/salt/cloud.providers.d/libvirt-local.conf
    - source: salt://cloud/files/libvirt-cloud-provider.conf
