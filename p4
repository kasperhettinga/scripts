#!/bin/bash
#

#****************************************************************
## Start timer:
START=$(date +%s)

#****************************************************************
## Set version info:
romname=Mackay_ROM
rv=2.9.4

#****************************************************************
## Check for missing parameters:

if [ "$1" != "p4"  ] && [ "$1" != "p4w"  ]
then
  echo "No target device defined"
  exit 0
fi

if [ "$2" != "a"  ] && [ "$2" != "cm"  ]
then
  echo "No build specification defined"
  exit 0
fi

#****************************************************************
## Set target:

if [ "$1" = "p4" ]
then
trgt=p4
fi

if [ "$1" = "p4w" ]
then
trgt=p4wifi
fi

cmrv=$rv-$trgt-cm
aorv=$rv-$trgt-aokp

if [ "$2" = "a"  ]
then
romversion=$aorv
fi

if [ "$2" = "cm"  ]
then
romversion=$cmrv
fi

#****************************************************************
## Set AOKP folder parameters:
if [ "$2" = "a"  ]
  then
  echo "Setting aokp folders"
  finalout=~/android/aokp/out/target/product/$trgt
  androidtop=~/android/aokp
  secsign=~/android/aokp/build/target/product/security
fi

#****************************************************************
## Set CM folder parameters:
if [ "$2" = "cm"  ]
  then
  echo "Setting CM folders"
  finalout=~/android/cm101/out/target/product/$trgt
  androidtop=~/android/cm101
  secsign=~/android/cm101/build/target/product/security
fi

#****************************************************************
## Clean environment:
if [ "$2" = "a"  ]
  then
  cd $androidtop
  make installclean
  rm $finalout/system/build.prop
  rm $finalout/obj/PACKAGING/target_files_intermediates/aokp_$trgt-target_files-eng.kasper.zip
  rm $finalout/obj/PACKAGING/target_files_intermediates/aokp_$trgt-target_files-eng.kasper/SYSTEM/build.prop
fi

if [ "$2" = "cm"  ]
  then
  cd $androidtop
  make installclean
  rm $finalout/system/build.prop
  rm $finalout/obj/PACKAGING/target_files_intermediates/cm_$trgt-target_files-eng.kasper.zip
  rm $finalout/obj/PACKAGING/target_files_intermediates/cm_$trgt-target_files-eng.kasper/SYSTEM/build.prop
fi

#****************************************************************
## Set ROM version:
if [ "$2" = "a"  ]
  then
  cd $androidtop/vendor/aokp
  sed "/Mackay/c\        ro.aokp.version=`echo $romname`_`echo $romversion`" $androidtop/vendor/aokp/configs/common_versions.mk > $androidtop/vendor/aokp/configs/common_versions.updated
  mv $androidtop/vendor/aokp/configs/common_versions.updated $androidtop/vendor/aokp/configs/common_versions.mk
  git add configs/common_versions.mk
  git commit -m "Bump ROM version to `echo $aorv`"
fi

if [ "$2" = "cm"  ]
  then
  cd $androidtop/vendor/cm
  sed "/Mackay/c\    CM_VERSION := `echo $romname`_`echo $romversion`" $androidtop/vendor/cm/config/common.mk > $androidtop/vendor/cm/config/common.updated
  mv $androidtop/vendor/cm/config/common.updated $androidtop/vendor/cm/config/common.mk
  git add config/common.mk
  git commit -m "Bump ROM version to `echo $cmrv`"
fi

#****************************************************************
## Make the build:
cd $androidtop/
. build/envsetup.sh && brunch $trgt

#****************************************************************
## Check whether build finished succesfully:
echo "Check whether the build finished succesfully"
if [ -e $finalout/`echo $romname`_`echo $romversion`.zip ]
then
  echo "Build finished succesfully"
else
  echo "Build not found, probably a compile error occured"
  exit 0
fi

#****************************************************************
## Move the ROM to the final ROM preparation stage:
mv $finalout/$romname* ~/android/scripts/finalize_p4_aokp

#****************************************************************
## Set name of final file:
zipname=`echo $romname`-`echo $romversion`

#****************************************************************
## Execute the final ROM preparation:
cd ~/android/scripts/finalize_p4_aokp
rm *.md5sum
echo "Extracting Mackay ROM"
unzip -q $romname* -d MackayExtract

echo "Copying the updater-script for $trgt"
cp updater-script_$trgt updater-script
cp updater-script MackayExtract/META-INF/com/google/android
rm updater-script

echo "Copying Gapps"
cp -R gapps/system/* MackayExtract/system

echo "Repacking Mackay ROM"
cd MackayExtract
zip -qr ../`echo $zipname`.zip ./
cd ..

echo "Copying fininalized build to AndroidFlash directory"
mv `echo $zipname`.zip ~/AndroidFlash/$trgt

echo "Cleaning environment"
rm -r MackayExtract
rm $romname*
cd $androidtop

#****************************************************************
## Report timer:
END=$(date +%s)
ELAPSED=$((END - START))
E_MIN=$((ELAPSED / 60))
E_SEC=$((ELAPSED - E_MIN * 60))
printf "${txtgrn}Elapsed: "
[ $E_MIN != 0 ] && printf "%d min(s) " $E_MIN
printf "%d sec(s)\n ${txtrst}" $E_SEC
