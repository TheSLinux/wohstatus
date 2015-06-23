#!/bin/bash

_check_mirror() {
  local _uri="${1:-}"

  TIMESTAMP="$(curl --connect-timeout 5 -sLo- "$_uri")"
  export TIMESTAMP

  if [[ -z "$TIMESTAMP" ]]; then
    echo "down Unable to get 'lastsync' information"
    return
  fi

  offset="$(
    ruby -rtime \
      -e 'puts ((Time.now - Time.at(ENV["TIMESTAMP"].to_i))/60).to_i')"

  if [[ -z "$offset" ]]; then
    echo "down Unable to detect time information from 'lastsync'"
  elif [[ "$offset" -ge 10080 ]]; then
    echo "down Mirror is useless (out-of-sync > 7 days)"
  elif [[ "$offset" -ge 360 ]]; then
    echo "limited Mirror is out of sync (offset > 6 hours)"
  elif [[ "$offset" -ge 120 ]]; then
    echo "info Mirror is out of sync (offset > 2 hours)"
  else
    echo "up Mirror is running well"
  fi
}

# ArchLinux (mirror)
_archlinux="$(_check_mirror http://f.archlinuxvn.org/archlinux/lastsync)"
_last_stat="$(./woh.rb --option3 < <(cat data/mirror-archlinux/*.yaml))"
if [[ "$_last_stat" != "$_archlinux" ]]; then
  echo "'$_last_stat' vs '$_archlinux'"
  echo y | ./add.sh data/mirror-archlinux $_archlinux
fi

# ArchLinux (fpt mirror)
_archlinux="$(_check_mirror http://mirror-fpt-telecom.fpt.net/archlinux/lastsync)"
_last_stat="$(./woh.rb --option3 < <(cat data/mirror-archlinux-fpt/*.yaml))"
if [[ "$_last_stat" != "$_archlinux" ]]; then
  echo "'$_last_stat' vs '$_archlinux'"
  echo y | ./add.sh data/mirror-archlinux-fpt $_archlinux
fi

# BlackArch (mirror)
_archlinux="$(_check_mirror http://f.archlinuxvn.org/blackarch/lastsync)"
_last_stat="$(./woh.rb --option3 < <(cat data/mirror-blackarch/*.yaml))"
if [[ "$_last_stat" != "$_archlinux" ]]; then
  echo "'$_last_stat' vs '$_archlinux'"
  echo y | ./add.sh data/mirror-blackarch $_archlinux
fi

# ArchLinux ARM (mirror)
_archlinux="$(_check_mirror http://vn.mirror.archlinuxarm.org/arm/sync)"
_last_stat="$(./woh.rb --option3 < <(cat data/mirror-archlinuxarm/*.yaml) | sed -e 's# (cf.*##g')"
if [[ "$_last_stat" != "$_archlinux" ]]; then
  echo y | ./add.sh data/mirror-archlinuxarm $_archlinux
fi
