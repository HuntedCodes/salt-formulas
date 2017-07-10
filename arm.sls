arm_toolchain:
  pkg.installed:
    - pkgs:
      - cross-gcc-dev
      - gcc-arm-none-eabi
      - binutils-arm-linux-gnueabi
      - binutils-arm-linux-gnueabihf

arm_emulation:
  pkg.installed:
    - pkgs:
      - libxen-4.4
      - qemu-user-static
      - qemu-system-arm
