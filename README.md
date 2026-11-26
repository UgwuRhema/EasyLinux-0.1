# Easy Linux

A minimal Linux-from-scratch style system: a BusyBox-based initramfs and a
QEMU disk image, booted with a custom kernel.

## What is tracked

This repository contains **build inputs only**:

| Path | Purpose |
| --- | --- |
| `Makefile` | Build/run entry points |
| `mkbusybox-links.sh` | Creates the BusyBox applet symlinks in `fs/bin` |
| `fs/init` | PID 1 script for the initramfs |
| `fs/etc/` | Hostname, hosts and `os-release` |
| `configs/busybox.config` | BusyBox build configuration |
| `some.c` | Small example/test program |

Build outputs are deliberately **not** tracked: `bzImage`, `fs.cpio.gz`,
`easy-linux.qcow2`, the generated `fs/bin` and `fs/lib64` contents, and the
BusyBox source tree. They are covered by `.gitignore`.

## Layout

```
.
├── Makefile
├── configs/busybox.config
├── fs/                  # root filesystem skeleton + generated content
│   ├── init
│   ├── etc/
│   ├── bin/             # generated (busybox + applets)
│   └── lib64/           # generated (shared libraries)
├── mkbusybox-links.sh
├── some.c
├── bzImage              # not tracked
├── fs.cpio.gz           # not tracked
└── easy-linux.qcow2     # not tracked
```

## Prerequisites

- A Linux host with `gcc`, `make`, `cpio`, `gzip`
- `qemu-system-x86_64` with KVM enabled
- BusyBox 1.39.x source
- A Linux kernel built for the target

## Build

### 1. BusyBox

Download and unpack BusyBox 1.39.x as `busybox/`, then build it with the
tracked configuration:

```sh
cp configs/busybox.config busybox/.config
make -C busybox olddefconfig
make -C busybox -j"$(nproc)"

mkdir -p fs/bin fs/lib64
cp busybox/busybox fs/bin/busybox
./mkbusybox-links.sh
```

`mkbusybox-links.sh` creates a curated set of applet symlinks by default; pass
`all` to link every compiled-in applet.

### 2. Kernel

Build your kernel separately and place the result at `./bzImage`:

```sh
cp /path/to/linux/arch/x86/boot/bzImage .
```

If you keep a kernel `.config`, add it under `configs/` so the build is
reproducible.

### 3. Initramfs

```sh
make initramfs
```

This packs `fs/` into `fs.cpio.gz`.

### 4. Disk image

The QEMU disk is local scratch space and is not tracked. Create it once:

```sh
qemu-img create -f qcow2 easy-linux.qcow2 7G
```

## Run

```sh
make
```

This boots `bzImage` with `fs.cpio.gz` and attaches `easy-linux.qcow2` as an
IDE drive.

## Publishing builds

Attach the built artifacts to a GitHub release instead of committing them:

```sh
gh release create v0.1 bzImage fs.cpio.gz easy-linux.qcow2
```

Users can then download the image without cloning hundreds of megabytes of
binary history. If you later need versioned binaries in Git itself, use Git
LFS — but release assets or an artifact store are usually simpler.
