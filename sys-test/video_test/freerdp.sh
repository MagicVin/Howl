#!/bin/bash

# v.xin.zhang@outlook.com
# Jan 6, 2022
# v1.0
# freerdp script: easy use for remoting windows10 from ubuntu18

hostname=DESKTOP-PM6DU0G
username=Zin
high=960
width=1280
xfreerdp \
  /v:$hostname \
  /u:$username \
  /network:modem \
  /compression \
  -themes -wallpaper \
  /rfx /gfx:avc444 \
  /bpp:16 \
  /auto-reconnect -glyph-cache \
  /audio-mode:1 /clipboard \
  /cer-ignore \
  /h:$high /w:$width \
  #/dynamic-resolution
