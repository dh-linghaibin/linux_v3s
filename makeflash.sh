mkfs.jffs2 -s 0x100 -e 0x10000 -p 0xAF0000 -d rootfs/ -o jffs2.img

dd if=/dev/zero of=flashimg.bin bs=16M count=1
dd if=u-boot-3s/u-boot-sunxi-with-spl.bin of=flashimg.bin bs=1K conv=notrunc
dd if=linux-zero-4.10.y/arch/arm/boot/dts/sun8i-v3s-licheepi-zero-dock.dtb of=flashimg.bin bs=1K seek=1024  conv=notrunc
dd if=linux-zero-4.10.y/arch/arm/boot/zImage of=flashimg.bin bs=1K seek=1088  conv=notrunc
dd if=jffs2.img of=flashimg.bin  bs=1K seek=5184  conv=notrunc