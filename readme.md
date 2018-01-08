考虑兼容性，现在系统默认50MHZ
 【吐槽】XBOOT 分享文件 16:30:49
"xboot.bin" 下载
【活跃】XBOOT(8192542) 16:31:01
给大家一个测试镜像
【活跃】XBOOT(8192542) 16:31:04
烧写方法
【活跃】XBOOT(8192542) 16:31:33
sunxi-fel -p spiflash-write 0 ~/xboot/xboot/output/xboot.bin
【活跃】XBOOT(8192542) 16:31:56
需要使用带spi flash烧写功能的sunxi-fel工具
【活跃】XBOOT(8192542) 16:32:12
或者自己拿编程器直接烧写，烧写到0地址
【活跃】XBOOT(8192542) 16:32:47
工具，可以从Icenowy的github 克隆
【活跃】XBOOT(8192542) 16:32:58
https://github.com/Icenowy/sunxi-tools.git
【活跃】XBOOT(8192542) 16:33:10
然后切换的spi-rebase分支


XBOOT 2017/9/12 9:38:09
先测试软件及硬件
XBOOT 2017/9/12 9:38:13
稍等

—— 2017/9/12 9:39:07


—— 2017/9/12 9:39:09
好的
9:39:41
XBOOT 2017/9/12 9:39:41
sunxi-fel spl xboot.bin; sunxi-fel -p write 0x40000000 xboot.bin; sunxi-fel exec 0x40000000;
XBOOT 2017/9/12 9:39:49
先用这个测试下

11:51:18
—— 2017/9/12 11:51:18
烧过一次xboot 就进不了Allwinner USB FEL 模式了
12:03:33
XBOOT 2017/9/12 12:03:33
短spi flash

—— 2017/9/12 12:04:43
哪两个角
XBOOT 2017/9/12 12:05:06
数据，什么的，短地就行

—— 2017/9/12 12:05:17
好的 我试试


交叉编译环境设置

export PATH=$PATH:/home/lhb/lhb/xboot/eclipse-mars-for-arm-gtk-linux-x86_64/compiler/arm-linux-gnueabihf/bin


make CROSS_COMPILE=arm-linux-gnueabihf- PLATFORM=arm32-licheepi


sudo ./sunxi-fel -p spiflash-write 0 /home/lhb/lhb/xboot/xboot/output/xboot.bin 


find name
grep -rl "Solomon SSD1307 framebuffer support" ./


bulind u-boot

lichee的uboot配置文件放在confgs文件目录下面，名称为
LicheePi_Zero_480x272LCD_defconfig 
LicheePi_Zero_800x480LCD_defconfig 
LicheePi_Zero_defconfig
这3个配置是根据不同的Zero显示设备进行的配置，使用其中之一即可，可以在uboot目录下执行命令
make LicheePi_Zero_defconfig
这样配置就生效了。
关于设备的配置引脚信息可以在arch/arm/dts的设备树下面进行查找。
通过查看arch/arm/dts/Makefile我们看到下面这段关于v3s的代码：
dtb-$(CONFIG_MACH_SUN8I_V3S) += \
        sun8i-v3s-licheepi-zero.dtb
我们基本可以找到对应的dtb文件就是sun8i-v3s-licheepi-zero.dtb
打开sun8i-v3s-licheepi-zero.dts（dtb是object文件，相当于*.o, dts相当于*.c）文件


编译uboot的需要生成.config文件来将该配置生效。
配置的生效有两步：
第一步，先将Zero默认的配置加载进来：

Zero已经将配置定制好了，执行相应的命令就可以生成了。下面是生成配置的命令
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- LicheePi_Zero_800x480LCD_defconfig

这个命令可以分为3个部分

设置变量ARCH值为arm
设置变量CROSS_COMPILE值为arm-linux-gnueabihf-
make LicheePi_Zero_800x480LCD_defconfig
最后一个make LicheePi_Zero_800x480LCD_defconfig才是重点，执行这条命令就可以对应生成一个编译所需要的配置文件.config


第一个time命令完全可以去掉，time主要为了计算该编译需要花费的时间

make ARCH=arm CROSS_COMPILE=/home/lhb/lhb/xboot/eclipse-mars-for-arm-gtk-linux-x86_64/compiler/arm-linux-gnueabihf/bin/arm-linux-gnueabihf-

export CROSS_COMPILE=/home/lhb/lhb/xboot/eclipse-mars-for-arm-gtk-linux-x86_64/compiler/arm-linux-gnueabihf/bin/arm-linux-gnueabihf-

make CROSS_COMPILE=/home/lhb/lhb/xboot/eclipse-mars-for-arm-gtk-linux-x86_64/compiler/arm-linux-gnueabihf/bin/arm-linux-gnueabihf-

make install COMPILE=/home/lhb/lhb/xboot/eclipse-mars-for-arm-gtk-linux-x86_64/compiler/arm-linux-gnueabihf/bin/arm-linux-gnueabihf-

sudo cp -P /home/lhb/lhb/xboot/eclipse-mars-for-arm-gtk-linux-x86_64/compiler/arm-linux-gnueabihf/lib/* rootfs/lib/ 

qemu-system-arm -M vexpress-a9 -m 512M -dtb extra_folder/vexpress-v2p-ca9.dtb -kernel extra_folder/zImage -append "root=/dev/mmcblk0 rw" -sd a9rootfs.ext3  


//make rootfs
mkfs.jffs2 -s 0x100 -e 0x20000 -p 0xAF0000 -d rootfs/ -o jffs2.img

dd if=/dev/zero of=flashimg.bin bs=16M count=1
dd if=u-boot-3s/u-boot-sunxi-with-spl.bin of=flashimg.bin bs=1K conv=notrunc
dd if=linux-zero-4.10.y/arch/arm/boot/dts/sun8i-v3s-licheepi-zero-dock.dtb of=flashimg.bin bs=1K seek=1024  conv=notrunc
dd if=linux-zero-4.10.y/arch/arm/boot/zImage of=flashimg.bin bs=1K seek=1088  conv=notrunc
dd if=jffs2.img of=flashimg.bin  bs=1K seek=5184  conv=notrunc

sudo sunxi-fel -p spiflash-write 0 flashimg.bin




//显示屏相关知识
@-- 因为你开了 fbcon 吧
boot.scr


使用主线uboot启动BSP内核，需要修改下启动脚本，放入BSP内核需要的script.bin配置文件（相当于主线linux的dtb）

修改boot.cmd:
setenv bootargs console=ttyS0,115200 panic=5 rootwait root=/dev/mmcblk0p2 earlyprintk rw
setenv bootm_boot_mode sec
setenv machid 1029
load mmc 0:1 0x41000000 uImage
load mmc 0:1 0x41d00000 script.bin
bootm 0x41000000

重新生成boot.scr:
mkimage -C none -A arm -T script -d boot.cmd boot.scr

将boot.scr放入第一分区。

再配置生成script.bin.
复制一份lichee/tools/pack/chips/sun8iw8p1/configs/tiger-cdr/sys_config.fex
修改其中的摄像头配置：
首先修改SD卡检测策略，设置为不检测，默认插入
sdc_detmode=3
使能RTL8723bs无线网卡的话，需要使能mmc1，也设置为不检测sd卡。


//error
[ ***]A start job is running for LSB: Raise network interfaces. (1min 20s / no limit)

以root用户身份打开“etc / network / interfaces”... 
如果有一个“allow hotplug”的行，则注释掉，保存并重启。如果这不适用于您的问题，然后回报...

vt100

//把输出映射到屏幕上
exec 1>/dev/tty1 2>&1


vim /etc/securetty




//good Software
1.
sudo apt-get install screenfetch
screenfetch

$screenfetch
         _,met$$$$$gg.           root@LicheePi
      ,g$$$$$$$$$$$$$$$P.        OS: Debian 
    ,g$$P""       """Y$$.".      Kernel: armv7l Linux 4.13.0-licheepi-zero+
   ,$$P'              `$$$.      Uptime: 3m
  ',$$P       ,ggs.     `$$b:    Packages: 265
  `d$$'     ,$P"'   .    $$$     Shell: 253
   $$P      d$'     ,    $$P     CPU: ARMv7 rev 5 (v7l)
   $$:      $$.   -    ,d$$'     RAM: 18MB / 53MB
   $$\;      Y$b._   _,d$P'     
   Y$$.    `.`"Y$$$$P"'         
   `$$b      "-.__              
    `Y$$                        
     `Y$$.                      
       `$$b.                    
         `Y$$b.                 
            `"Y$b._             
                `""""           


Debian修改ssh端口和禁止root远程登陆设置
  linux修改端口22
  vi /etc/ssh/sshd_config
  找到#port 22
  将前面的#去掉,然后修改端口 port 1234
  重启服务就OK了
  service sshd restart
  或
  /etc/init.d/ssh restart
  为增强安全
  先增加一个普通权限的用户,并设置密码
  useradd test
  passwd test
  然后禁止ROOT远程SSH登录：
  vi /etc/ssh/sshd_config
  把其中的
  PermitRootLogin yes
  改为
  PermitRootLogin no
  重启sshd服务
  service sshd restart
  或
  /etc/init.d/ssh restart
  远程管理用普通用户test登录,然后用 su root 切换到root用户就可以拿到最高权限





  ssd1306: ssd1306@3c {
    compatible = "solomon,ssd1306fb-i2c";
    reg = <0x3c>;
    solomon,width = <128>;
    solomon,height = <32>;
    solomon,com-invdir = <1>;
    solomon,prechargep1 = <0x1>;
    solomon,prechargep2 = <0xf>;
    solomon,page-offset = <0>;
  };


  ssd1306: ssd1306@3c {
    compatible = "oled12864,ssd1306";
    reg = <0x3c>;
  };


make ARCH=arm CROSS_COMPILE=/home/lhb/lhb/xboot/eclipse-mars-for-arm-gtk-linux-x86_64/compiler/arm-linux-gnueabihf/bin/arm-linux-gnueabihf-

make ARCH=arm xconfig
