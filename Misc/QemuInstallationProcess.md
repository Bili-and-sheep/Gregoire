# Qemu Installation Process

## Necessary Packages

```bash
apt-get install build-essential python3-venv python3-pip python3-sphinx python3-sphinx-rtd-theme ninja-build meson libglib2.0-dev flex bison
```

Clone Qemu repository :
```bash
git clone https://github.com/qemu/qemu.git
```

```bash
cd qemu
mkdir build
cd build
../configure
make
```


## Add Qemu to your PATH
```bash
vim /etc/bash.bashrc /// (at the end of the page add)
```
PATH=/YourPath/qemu/build:$PATH


## ⚠️ IF bios-256k.bin not found ⚠️

change :
PATH=/YourPath/qemu/build:$PATH 
to 
PATH=/YourPath/qemu/build:/YourPath/qemu/pv-bios:$PATH
