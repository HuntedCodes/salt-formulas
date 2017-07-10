common_file_packages:
  pkg.installed:
    - pkgs:
      - unzip
      - p7zip
      - dos2unix
      - tree
      - rename
      - wipe

common_network_packages:
  pkg.installed:
    - pkgs:
      - net-tools
      - curl
