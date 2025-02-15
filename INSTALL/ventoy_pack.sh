#!/bin/sh

if [ "$1" = "CI" ]; then
    OPT='-dR'
else
    OPT='-a'
fi

dos2unix -q ./tool/ventoy_lib.sh
dos2unix -q ./tool/VentoyWorker.sh
dos2unix -q ./tool/VentoyGTK.glade
dos2unix -q ./tool/distro_gui_type.json

. ./tool/ventoy_lib.sh

GRUB_DIR=../GRUB2/INSTALL
LANG_DIR=../LANGUAGES

if ! [ -d $GRUB_DIR ]; then
    echo "$GRUB_DIR not exist"
    exit 1
fi


cd ../IMG
sh mkcpio.sh
sh mkloopex.sh
cd -

cd ../Unix
sh pack_unix.sh
cd -

LOOP=$(losetup -f)
mknod -m 666  $LOOP b 7 0

rm -f img.bin
dd if=/dev/zero of=img.bin bs=1M count=256 status=none

losetup -P $LOOP img.bin 

while ! grep -q 524288 /sys/block/${LOOP#/dev/}/size 2>/dev/null; do
    echo "wait $LOOP ..."
    sleep 1
done

format_ventoy_disk_mbr 0 $LOOP fdisk

$GRUB_DIR/sbin/grub-bios-setup  --skip-fs-probe  --directory="./grub/i386-pc"  $LOOP

curver=$(get_ventoy_version_from_cfg ./grub/grub.cfg)

tmpmnt=./ventoy-${curver}-mnt

rm -rf $tmpmnt
mkdir -p $tmpmnt

mount ${LOOP}p2  $tmpmnt 

mkdir -p $tmpmnt/grub

# First copy grub.cfg file, to make it locate at front of the part2
cp $OPT ./grub/grub.cfg     $tmpmnt/grub/

ls -1 ./grub/ | grep -v 'grub\.cfg' | while read line; do
    cp $OPT ./grub/$line $tmpmnt/grub/
done

#tar help txt
cd $tmpmnt/grub/
tar czf help.tar.gz ./help/
rm -rf ./help
cd ../../

#tar menu txt & update menulang.cfg
cd $tmpmnt/grub/

vtlangtitle=$(grep VTLANG_LANGUAGE_NAME menu/zh_CN.json | awk -F\" '{print $4}')
echo "menuentry \"zh_CN  -  $vtlangtitle\" --class=menu_lang_item --class=debug_menu_lang --class=F5tool {" >> menulang.cfg
echo "    vt_load_menu_lang zh_CN"  >> menulang.cfg
echo "}"  >> menulang.cfg

ls -1 menu/ | grep -v 'zh_CN' | sort | while read vtlang; do
    vtlangname=${vtlang%.*}
    vtlangtitle=$(grep VTLANG_LANGUAGE_NAME menu/$vtlang | awk -F\" '{print $4}')
    echo "menuentry \"$vtlangname  -  $vtlangtitle\" --class=menu_lang_item --class=debug_menu_lang --class=F5tool {" >> menulang.cfg
    echo "    vt_load_menu_lang $vtlangname"  >> menulang.cfg
    echo "}"  >> menulang.cfg
done
echo "menuentry \"\$VTLANG_RETURN_PREVIOUS\" --class=vtoyret VTOY_RET {" >> menulang.cfg
echo "        echo \"Return ...\"" >> menulang.cfg
echo "}" >> menulang.cfg

tar czf menu.tar.gz ./menu/
rm -rf ./menu
cd ../../



cp $OPT ./ventoy   $tmpmnt/
cp $OPT ./EFI   $tmpmnt/
cp $OPT ./tool/ENROLL_THIS_KEY_IN_MOKMANAGER.cer $tmpmnt/


mkdir -p $tmpmnt/tool
# cp $OPT ./tool/i386/mount.exfat-fuse     $tmpmnt/tool/mount.exfat-fuse_i386
# cp $OPT ./tool/x86_64/mount.exfat-fuse   $tmpmnt/tool/mount.exfat-fuse_x86_64
# cp $OPT ./tool/aarch64/mount.exfat-fuse  $tmpmnt/tool/mount.exfat-fuse_aarch64
# to save space
dd status=none bs=1024 count=16  if=./tool/i386/vtoycli    of=$tmpmnt/tool/mount.exfat-fuse_i386
dd status=none bs=1024 count=16  if=./tool/x86_64/vtoycli  of=$tmpmnt/tool/mount.exfat-fuse_x86_64
dd status=none bs=1024 count=16  if=./tool/aarch64/vtoycli of=$tmpmnt/tool/mount.exfat-fuse_aarch64


# rm -f $tmpmnt/grub/i386-pc/*.img
mkdir -p $tmpmnt/install
dd if=$LOOP of=$tmpmnt/install/boot.img bs=1 count=512  status=none
dd if=$LOOP of=$tmpmnt/install/core.img bs=512 count=2047 skip=1 status=none
cd $tmpmnt/../
tar -czvf ventoy-${curver}.tar.gz $tmpmnt
umount $tmpmnt && rm -rf $tmpmnt
losetup -d $LOOP && rm -f img.bin



rm -f log.txt
rm -f sha256.txt

