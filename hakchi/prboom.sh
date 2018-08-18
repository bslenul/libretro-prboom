#!/bin/sh -e

source /etc/preinit
script_init

self="$(readlink -f "$0")"
name="$(basename "$self" .sh)"
cdir="$(dirname "$self")"
code="$(basename "$cdir")"
doomsaves="/var/saves/$code"

mkdir -p "$doomsaves"
[ -f "$doomsaves/save.sram" ] || touch "$doomsaves/save.sram"
cd "$cdir/$name"
[ -f "$name.txt" ] || touch "$name.txt"
if [ "$(cat /dev/clovercon1)" = 0800 ] || [ -z "$(cat "$name.txt")" ]; then
  decodepng "$cdir/$name/$name.png" > /dev/fb0
  until button_id="$(cat /dev/clovercon1 | grep "0200\|0002\|0001\|0100\|0400\|4000")"; do
    usleep 50000
  done
  if [ "$button_id" = 4000 ]; then
    [ "$(ls -d * | grep -iw doom1)" ] && doom="$(ls -d * | grep -iw doom1)"
  fi
  if [ "$button_id" = 0100 ]; then
    [ "$(ls -d * | grep -iw doom)" ] && doom="$(ls -d * | grep -iw doom)"
  fi
  if [ "$button_id" = 0200 ]; then
    [ "$(ls -d * | grep -iw doom2)" ] && doom="$(ls -d * | grep -iw doom2)"
  fi
  if [ "$button_id" = 0002 ]; then
    [ "$(ls -d * | grep -iw tnt)" ] && doom="$(ls -d * | grep -iw tnt)"
  fi
  if [ "$button_id" = 0001 ]; then
    [ "$(ls -d * | grep -iw plutonia)" ] && doom="$(ls -d * | grep -iw plutonia)"
  fi
  [ "$button_id" = 0400 ] || [ -z "$doom" ] && exit 1
  if [ "$(ls "$doom" | grep -i "$doom.wad")" ]; then
    wad="$(readlink -f "$doom/`ls "$doom" | grep -i "$doom.wad"`")"
  else
    exit 1
  fi
  echo "$wad" > "$name.txt"
else
  wad="$(cat "$name.txt")"
  doom="$(basename `dirname "$wad"`)"
fi
[ "$(ls "$doom" | grep -i "$doom.png")" ] && png="$(ls "$doom" | grep -i "$doom.png")"
[ -z "$png" ] || decodepng "$doom/$png" > /dev/fb0
mkdir -p "$doomsaves/$doom"
[ -z "$(ls "$doomsaves/$doom")" ] || cp "$doomsaves/$doom/"* "$doom"
[ -f "$doom/$name.wad" ] || touch "$doom/$name.wad"
while [ "$(mount | grep "$name.wad")" ]; do
  umount "$(mount | grep -m 1 "$name.wad" | awk '{print $3}')"
done
mount -o bind "$name.wad" "$doom/$name.wad"
uistop
echo "retroarch-clover-child ../../..$cdir/$name/$name $wad --custom-loadscreen ../../../../../../..$cdir/$name/$doom/$png; \
umount $cdir/$name/$doom/$name.wad; \
mv -f $cdir/$name/$doom/*.dsg $doomsaves/$doom" > /var/exec.flag
