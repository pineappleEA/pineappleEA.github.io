#!/bin/bash

zenity --question --timeout=10 --title="yuzu updater" --text="New update available. Update now?" --icon-name=yuzu --window-icon=yuzu.svg --height=80 --width=400
answer=$?

if [ "$answer" -eq 0 ]; then 
	$APPDIR/usr/bin/AppImageUpdate $PWD/yuzu-x86_64.AppImage
elif [ "$answer" -eq 1 ]; then
	$APPDIR/AppRun-patched
elif [ "$answer" -eq 5 ]; then
	$APPDIR/AppRun-patched
fi
exit 0
