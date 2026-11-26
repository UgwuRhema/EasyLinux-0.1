#!/bin/sh
# Create relative busybox applet symlinks in fs/bin.
#
# Usage:
#   ./mkbusybox-links.sh          # curated rescue/admin set
#   ./mkbusybox-links.sh all      # every applet compiled into busybox
#
# Existing files and symlinks are never overwritten.

set -eu

root=$(CDPATH= cd "$(dirname "$0")" && pwd)
bin="$root/fs/bin"
bb="$bin/busybox"
mode=${1:-curated}

mkdir -p "$bin"

if [ ! -x "$bb" ]; then
	echo "error: $bb not found or not executable" >&2
	exit 1
fi

case "$mode" in
all)
	applets=$("$bb" --list)
	;;
curated)
	applets='
ash cat echo printf test [ true false env printenv pwd clear reset tty stty
date sleep usleep seq yes watch timeout nohup setsid
uname arch hostname dmesg free uptime whoami id groups logname who users
which xargs find tree lsof fuser mountpoint
chmod chown chgrp install mkfifo mknod stat du sync fsync dd
readlink realpath basename dirname mktemp rmdir link unlink truncate fallocate fstrim
shred flock
head tail less more grep egrep fgrep sed awk cut sort uniq wc tr tee
diff cmp patch comm join paste nl rev tac fold expand unexpand split
strings hexdump od xxd md5sum sha1sum sha256sum sha512sum cksum crc32
base64 base32 uuencode uudecode ascii ed sum getopt
tar cpio gzip gunzip zcat bzip2 bunzip2 bzcat xz unxz xzcat lzma unlzma lzcat lzop unzip
kill killall pidof pgrep pkill pstree pmap pwdx
chroot nsenter unshare setpriv su login getty sulogin passwd chpasswd
adduser addgroup deluser delgroup nologin
time nice renice ionice chrt taskset nproc
umount switch_root pivot_root blkid findfs blockdev losetup mkswap swapon swapoff swaplabel
fdisk mkfs.minix fsck fsck.minix mke2fs mkdosfs partprobe readahead hdparm hwclock rtcwake
eject blkdiscard devmem freeramdisk fsfreeze fdformat
insmod rmmod modprobe depmod lsmod modinfo
ifconfig route arp ping ping6 traceroute traceroute6 netstat nc wget
nslookup dnsdomainname udhcpc ipcalc ether-wake brctl vconfig ifup ifdown tunctl
telnet ftpget ftpput tftp whois zcip
mdev makedevs dumpkmap loadkmap setfont loadfont chvt deallocvt openvt
setconsole setlogcons kbd_mode showkey setkeycodes watchdog
lspci lsusb lsscsi hd fdflush
syslogd klogd logread logger seedrng
bc dc expr factor shuf tsort cal cryptpw mkpasswd uuidgen
dos2unix unix2dos hexedit microcom cttyhack run-parts script uevent
halt poweroff reboot
'
	;;
*)
	echo "usage: $0 [curated|all]" >&2
	exit 2
	;;
esac

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
"$bb" --list >"$tmp"

added=0
skipped=0
missing=0

for name in $applets; do
	if [ -e "$bin/$name" ] || [ -L "$bin/$name" ]; then
		skipped=$((skipped + 1))
		continue
	fi

	if ! grep -Fxq -- "$name" "$tmp"; then
		echo "warning: '$name' is not a compiled-in busybox applet" >&2
		missing=$((missing + 1))
		continue
	fi

	ln -s busybox "$bin/$name"
	added=$((added + 1))
done

echo "added $added symlinks, skipped $skipped existing, $missing unavailable"
