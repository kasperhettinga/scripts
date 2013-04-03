#!/sbin/sh
# 
# /system/addon.d/50-gapps.sh
#

. /tmp/backuptool.functions

list_files() {
cat <<EOF
app/CalendarGoogle.apk app/Calendar.apk
app/ChromeBookmarksSyncAdapter.apk
app/ConfigUpdater.apk
app/GmsCore.apk
app/GoogleBackupTransport.apk
app/GoogleContactsSyncAdapter.apk
app/GoogleFeedback.apk
app/GoogleLoginService.apk
app/GooglePartnerSetup.apk
app/GoogleServicesFramework.apk
app/GoogleTTS.apk
app/LatinImeDictionaryPack.apk
app/MediaUploader.apk
app/NetworkLocation.apk
app/OneTimeInitializer.apk
app/Phonesky.apk
app/SetupWizard.apk app/Provision.apk
app/Talk.apk
app/Velvet.apk app/QuickSearchBox.apk
app/VoiceSearchStub.apk
etc/permissions/com.google.android.maps.xml
etc/permissions/com.google.android.media.effects.xml
etc/permissions/com.google.widevine.software.drm.xml
etc/permissions/features.xml
framework/com.google.android.maps.jar
framework/com.google.android.media.effects.jar
framework/com.google.widevine.software.drm.jar
lib/libfilterpack_facedetect.so
lib/libfrsdk.so
lib/libgoggles_clientvision.so
lib/libgoogle_recognizer_jni_l.so
lib/libgtalk_jni.so
lib/liblightcycle.so
lib/libpatts_engine_jni_api.so
lib/libspeexwrapper.so
lib/libvideochat_stabilize.so
lib/libvorbisencoder.so
media/LMprec_508.emd
media/PFFprec_600.emd
EOF
}

case "$1" in
  backup)
    list_files | while read FILE DUMMY; do
      backup_file $S/$FILE
    done
  ;;
  restore)
    list_files | while read FILE REPLACEMENT; do
      R=""
      [ -n "$REPLACEMENT" ] && R="$S/$REPLACEMENT"
      [ -f "$C/$S/$FILE" ] && restore_file $S/$FILE $R
    mkdir -p /system/usr/srec
    done
  ;;
  pre-backup)
    # Stub
  ;;
  post-backup)
    # Stub
  ;;
  pre-restore)
    # Stub
  ;;
  post-restore)
    # Stub
  ;;
esac
