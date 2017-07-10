gnu_toolchain:
  pkg.installed:
    - pkgs:
      - binutils
      - gcc
      - gcc-4.9-multilib
      - gdb
      - nasm
      - make
      - cmake

c_libraries:
  pkg.installed:
    - pkgs:
      - libssl-dev
      - libxslt-dev
      - libxml2-dev
