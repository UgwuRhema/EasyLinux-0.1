all: run

run:
	$(MAKE) -C . make 2> /dev/null

initramfs:
	$(MAKE) -C . init

init:
	cd fs && find . | cpio -o -H newc --owner=root:root | gzip -9 > ../fs.cpio.gz
	cd ..

make:
	qemu-system-x86_64 \
		-enable-kvm \
		-machine q35 \
		-cpu host \
		-kernel bzImage \
		-initrd fs.cpio.gz \
		-drive format=qcow2,file=easy-linux.qcow2,if=ide\
		-m 1024 \
		-smp 4 \
		-display gtk \
		-vga std
