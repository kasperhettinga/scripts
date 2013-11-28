#!/bin/bash
#

#****************************************************************
## Start timer:
START=$(date +%s)

#****************************************************************
## Check for missing parameters:

if [ "$1" != "s"  ] && [ "$1" != "p4"  ] && [ "$1" != "p4t"  ] && [ "$1" != "p4v"  ] && [ "$1" != "p4w"  ] && [ "$1" != "p970"  ] && [ "$1" != "m7ul"  ]
then
  echo "No target device defined"
  exit 0
fi

#****************************************************************
## Set target:

if [ "$1" = "s" ]
then
trgt=galaxysmtd
fi

if [ "$1" = "s2" ]
then
trgt=i9100
fi

if [ "$1" = "p4" ]
then
trgt=p4
fi

if [ "$1" = "p4t" ]
then
trgt=p4tmo
fi

if [ "$1" = "p4v" ]
then
trgt=p4vzw
fi

if [ "$1" = "p4w" ]
then
trgt=p4wifi
fi

if [ "$1" = "p970" ]
then
trgt=p970
fi


if [ "$1" = "m7ul" ]
then
trgt=m7ul
fi

#****************************************************************
## Set basic folder parameters:
echo "Setting folders"
finalout=~/android/pac/out/target/product/$trgt
androidtop=~/android/pac
secsign=~/android/pac/build/target/product/security

#****************************************************************
## Start the build:
echo "An Infamous PAC ROM will be build for $trgt"

#****************************************************************
## Clean environment:
cd $androidtop
rm $finalout/system/build.prop
rm $finalout/obj/PACKAGING/target_files_intermediates/pac_$trgt-target_files-eng.kasper.zip
rm $finalout/obj/PACKAGING/target_files_intermediates/pac_$trgt-target_files-eng.kasper/SYSTEM/build.prop

#****************************************************************
## Make the build:
cd $androidtop/

. ./vendor/pac/tools/colors

eval $(grep "^PAC_VERSION_" vendor/pac/config/pac_common.mk | sed 's/ *//g')
VERSION="$PAC_VERSION_MAJOR.$PAC_VERSION_MINOR.$PAC_VERSION_MAINTENANCE"

rm -f out/target/product/$trgt/obj/KERNEL_OBJ/.version

make installclean

. build/envsetup.sh
breakfast "pac_$trgt-userdebug"
export USE_CCACHE=1
export WITH_DEXPREOPT=true
export CM_FIXUP_COMMON_OUT=1
export TARGET_USE_O_LEVEL_3=true
# brunch "pac_$trgt-userdebug"
make -j2 bacon

vendor/pac/tools/squisher

rm -f out/target/product/$trgt/cm-*.*
rm -f out/target/product/$trgt/pac_*-ota*.zip

#****************************************************************
## Copy the build:
echo "Copying fininalized build to AndroidFlash directory"
mv $finalout/pac_*.zip ~/AndroidFlash/$trgt

#****************************************************************
## Report timer:
END=$(date +%s)
ELAPSED=$((END - START))
E_MIN=$((ELAPSED / 60))
E_SEC=$((ELAPSED - E_MIN * 60))
printf "${txtgrn}Elapsed: "
[ $E_MIN != 0 ] && printf "%d min(s) " $E_MIN
printf "%d sec(s)\n ${txtrst}" $E_SEC
