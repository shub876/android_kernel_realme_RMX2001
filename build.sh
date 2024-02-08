#!/bin/bash

function compile() 
{
source ~/.bashrc && source ~/.profile
export LC_ALL=C && export USE_CCACHE=1
ccache -M 100G
export ARCH=arm64
export KBUILD_BUILD_HOST="ECLIPSExDEV"
export KBUILD_BUILD_USER="Shub"
git clone --depth=1 https://gitlab.com/LeCmnGend/proton-clang.git -b clang-13 clang

rm -rf out
mkdir out
rm -rf Anykernel3
rm -rf error.log

make O=out ARCH=arm64 RMX2001_defconfig
PATH="${PWD}/clang/bin:${PWD}/clang/bin:${PWD}/clang/bin:${PATH}" \
make -j$(nproc --all) O=out \
                      ARCH=arm64 \
                      CC="clang" \
                      LD=ld.lld \
                      STRIP=llvm-strip \
                      AS=llvm-as \
		              AR=llvm-ar \
		              NM=llvm-nm \
		              OBJCOPY=llvm-objcopy \
		              OBJDUMP=llvm-objdump \
                      CLANG_TRIPLE=aarch64-linux-gnu- \
                      CROSS_COMPILE="${PWD}/clang/bin/aarch64-linux-gnu-" \
                      CROSS_COMPILE_ARM32="${PWD}/clang/bin/arm-linux-gnueabi-" \
                      CONFIG_NO_ERROR_ON_MISMATCH=y 2>&1 | tee error.log 
}

function zupload()
{
git clone --depth=1 https://github.com/shub876/Anykernel3.git -b rui1 Anykernel3
cp out/arch/arm64/boot/Image.gz-dtb Anykernel3
cd Anykernel3
zip -r9 ECLIPSE-OSS-KERNEL-RMX2001-Q.zip *
curl --upload-file "ECLIPSE-OSS-KERNEL-RMX2001-Q.zip" https://free.keep.sh
curl bashupload.com -T ECLIPSE-OSS-KERNEL-RMX2001-Q.zip
}
compile
zupload
