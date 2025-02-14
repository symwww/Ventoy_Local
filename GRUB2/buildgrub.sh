#!/bin/bash

VT_GRUB_DIR=$PWD

rm -rf INSTALL
rm -rf SRC
rm -rf NBP
rm -rf PXE

mkdir SRC
mkdir NBP
mkdir PXE

tar -xf grub-2.04.tar.xz -C ./SRC/

/bin/cp -a ./MOD_SRC/grub-2.04  ./SRC/

cd ./SRC/grub-2.04


# build for x86_64-efi
echo '======== build grub2 for x86_64-efi ==============='
make distclean
./autogen.sh
./configure  --with-platform=efi --prefix=$VT_GRUB_DIR/INSTALL/
make -j 16 || exit 1
sh install.sh  uefi


#build for i386-efi
echo '======== build grub2 for i386-efi ==============='
make distclean
./autogen.sh
./configure --target=i386 --with-platform=efi  --prefix=$VT_GRUB_DIR/INSTALL/
make -j 16 || exit 1
sh install.sh  i386efi



#build for arm64 EFI
echo '======== build grub2 for arm64-efi ==============='
PATH=$PATH:/opt/gcc-linaro-7.4.1-2019.02-x86_64_aarch64-linux-gnu/bin
make distclean
./autogen.sh
./configure  --prefix=$VT_GRUB_DIR/INSTALL/ \
--target=aarch64 --with-platform=efi \
--host=x86_64-linux-gnu  \
HOST_CC=x86_64-linux-gnu-gcc \
BUILD_CC=gcc \
TARGET_CC=aarch64-linux-gnu-gcc   \
TARGET_OBJCOPY=aarch64-linux-gnu-objcopy \
TARGET_STRIP=aarch64-linux-gnu-strip TARGET_NM=aarch64-linux-gnu-nm \
TARGET_RANLIB=aarch64-linux-gnu-ranlib
make -j 16 || exit 1
sh install.sh arm64


#build for mips64el EFI
#http://ftp.loongnix.org/os/loongnix-server/1.7/os/Source/SPackages/grub2-2.02-0.40.lns7.14.loongnix.src.rpm
make distclean
./autogen.sh
./configure  --prefix=/home/share/Ventoy/GRUB2/INSTALL/ \
--target=mips64el --with-platform=efi \
--host=x86_64-linux-gnu  \
HOST_CC=x86_64-linux-gnu-gcc \
BUILD_CC=gcc \
TARGET_CC="mips-linux-gnu-gcc -mabi=64 -Wno-error=cast-align -Wno-error=misleading-indentation" \
TARGET_OBJCOPY=mips-linux-gnu-objcopy \
TARGET_STRIP=mips-linux-gnu-strip TARGET_NM=mips-linux-gnu-nm \
TARGET_RANLIB=mips-linux-gnu-ranlib
make -j 16 || exit 1
sh install.sh mips64el



# build for i386-pc
echo '======== build grub2 for i386-pc ==============='
make distclean
./autogen.sh
./configure --target=i386 --with-platform=pc --prefix=$VT_GRUB_DIR/INSTALL/
make -j 16 || exit 1
sh install.sh



cd ../../

