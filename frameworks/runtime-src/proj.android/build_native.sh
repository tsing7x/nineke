#!/usr/bin/env bash
export NDK_DEBUG=1
$DIR/build_native_release.sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APP_ROOT="$DIR/.."
APP_ANDROID_ROOT="$DIR"

echo "copy libs"
cp -rf "$APP_ROOT"/proj.android.lib.xinge/xingelibs/armeabi/ "$APP_ANDROID_ROOT"/libs/armeabi/

echo "override copy res_th"
cp -rf "$APP_ROOT"/res_th/ "$APP_ANDROID_ROOT"/assets/res/

echo "override copy scripts.th"
cp -rf "$APP_ROOT"/scripts.th/ "$APP_ANDROID_ROOT"/assets/scripts/

