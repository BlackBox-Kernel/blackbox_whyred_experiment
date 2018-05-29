#
# Copyright © 2016, Kunal Kene "kunalkene1797" <kunalkene1797@gmail.com>
#
# This software is licensed under the terms of the GNU General Public
# License version 2, as published by the Free Software Foundation, and
# may be copied, distributed, and modified under those terms.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# Please maintain this if you use this script or any part of it

# Init Script
KERNEL_DIR=$PWD
KERNEL="Image.gz-dtb"
KERN_IMG=$KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb
BUILD_START=$(date +"%s")
ANYKERNEL_DIR=/root/AnyKernel2
EXPORT=yes
EXPORT_DIR=/root/flashablezips

# Make Changes to this before release
ZIP_NAME="BlackBox-1.0"
BASE_VER="BlackBox"
VER="-v1.0-$(date +"%Y-%m-%d"-%H%M)-"


# Color Code Script
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White
nocol='\033[0m'         # Default

# Tweakable Options Below
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="KunalKene1797"
export KBUILD_BUILD_HOST="PhantomBlack"
export CROSS_COMPILE="/root/aarch64-linux-android-4.9/bin/aarch64-linux-android-"
export KBUILD_COMPILER_STRING=$(/root/platform_prebuilts_clang_host_linux-x86/clang-4053586/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')


# Compilation Scripts Are Below
echo -e "${green}"
echo "--------------------------------------------------------"
echo "      Initializing build to compile Ver: $VER    "
echo "--------------------------------------------------------"

echo -e "$yellow***********************************************"
echo "         Creating Output Directory: out      "
echo -e "***********************************************$nocol"

mkdir -p out

echo -e "$red***********************************************"
echo "          Cleaning Up Before Compile          "
echo -e "***********************************************$nocol"

make O=out clean 
make O=out mrproper

echo -e "$yellow***********************************************"
echo "          Initialising DEFCONFIG        "
echo -e "***********************************************$nocol"

make O=out ARCH=arm64 whyred-perf_defconfig

echo -e "$yellow***********************************************"
echo "          Cooking BlackBox        "
echo -e "***********************************************$nocol"

make -j$(nproc --all) O=out ARCH=arm64 \
					  CC="/root/platform_prebuilts_clang_host_linux-x86/clang-4053586/bin/clang" \
                      CLANG_TRIPLE="aarch64-linux-gnu-"

# If the above was successful
if [[ `ls ${ZIMAGE_DIR}/${KERNEL} 2>/dev/null | wc -l` != "0" ]]; then
   BUILD_RESULT_STRING="BUILD SUCCESSFUL"


   # Make the zip file
   echo "MAKING FLASHABLE ZIP"

   cp -vr ${ZIMAGE_DIR}/${KERNEL} ${ANYKERNEL_DIR}/zImage
   cd ${ANYKERNEL_DIR}
   zip -r9 ${ZIP_NAME}.zip * -x README ${ZIP_NAME}.zip

else
   BUILD_RESULT_STRING="BUILD FAILED"
fi

NOW=$(date +"%m-%d")
ZIP_LOCATION=${ANYKERNEL_DIR}/${ZIP_NAME}.zip
ZIP_EXPORT=${EXPORT_DIR}/${NOW}
ZIP_EXPORT_LOCATION=${EXPORT_DIR}/${NOW}/${ZIP_NAME}.zip

if [[ "${EXPORT}" == "yes" ]]; then
	rm -rf ${ZIP_EXPORT}
	mkdir ${ZIP_EXPORT}
	cp ${ZIP_LOCATION} ${ZIP_EXPORT}
fi

cd ${HOME}

# End the script
echo "${BUILD_RESULT_STRING}!"

DATE_END=$(date +"%s")
DIFF=$((${DATE_END} - ${DATE_START}))

echo -e ${RED}"SCRIPT DURATION: $((${DIFF} / 60)) MINUTES AND $((${DIFF} % 60)) SECONDS"
if [[ "${BUILD_RESULT_STRING}" == "BUILD SUCCESSFUL" ]]; then
   	if [[ "${EXPORT}" == "yes" ]]; then
		echo -e "ZIP LOCATION: ${ZIP_EXPORT_LOCATION}"
		echo -e "SIZE: $( du -h ${ZIP_EXPORT_LOCATION} | awk '{print $1}' )"
	else
   		echo -e "ZIP LOCATION: ${ZIP_LOCATION}"
   		echo -e "SIZE: $( du -h ${ZIP_LOCATION} | awk '{print $1}' )"
	fi
fi
echo -e ${RESTORE}
