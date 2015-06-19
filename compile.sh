#!/bin/bash

# Purpose: Compile everything to static status page
# Author : Anh K. Huynh
# Date   : 2015 Jun 19th
# License: MIT

__html_head() {
  local _subtitle=""
  if [[ -n "${1:-}" ]]; then
    _subtitle=" - ${@}"
  fi

  cat <<EOF

<!DOCTYPE html>
<html lang="en">
  <title>${WOHSTATUS_TITLE:-WohStatus}${_subtitle}</title>
  <head>
  <style>
  <!--
  body {
    width: 100%;
  }

  table {
    border-collapse: collapse;
  }
  td {
    border: 1px solid  #e4e4e4;
    padding: 10px;
  }
  td.status {
    width: 64px;
    text-align: center;
  }
  td.service {
    text-align: center;
  }
  img.icon {
    width: 16px;
    height: 16px;
  }

  @media screen and (max-device-width: 500px){
    body {
      width: 100%;
      padding-right: 0px;
      padding-left: 0px;
    }
    td.status {
      width: 20px;
    }
  }
  -->
  </style>
  </head>
  <body>
  <h3>${WOHSTATUS_TITLE:-WohStatus}${_subtitle}</h3>
EOF

}

__html_tail() {
  cat <<'EOF'

<h3>Status Legend</h3>
<ul>
  <li>
    <img class="icon" src="./images/up.png" /> Service is up and running
  </li>
  <li>
    <img class="icon" src="./images/down.png" /> Service is down
  </li>
  <li>
    <img class="icon" src="./images/limited.png" /> Service is running but has limited function
  </li>
  <li>
    <img class="icon" src="./images/maintenance.png" /> Service is being maintained
  </li>
  <li>
    <img class="icon" src="./images/bug.png" /> Unknown status
  </li>
  <li>
    <img class="icon" src="./images/info.png" /> Information
  </li>
</ul>

<h3><a href="https://github.com/icy/wohstatus">Powered by <em>WohStatus</em></a></h3>
<h3><a href="https://github.com/twilio/stashboard">Icons come from Stashboard</a></h3>
</body>
</html>
EOF

}


__option1() {
  __html_head

  echo "<table>"
  echo "<tr>"
  echo "  <td class=\"service\"><strong>Service</strong></td>"
  for offset in 0 1 2 3 4 5 6; do
    echo "  <td class=\"status\"><strong>$(date "+%b %d" --date="-$offset day")</strong></td>"
  done
  echo "</tr>"

  while read DIR; do
    if [[ -f "$DIR/ignore" ]]; then
      echo >&2 ":: $FUNCNAME: Ignore '$DIR'"
      continue
    fi

    export SERVICE="$(basename $DIR)"
    echo "<tr>"
    ./woh.rb --option1 < <(cat "$DIR"/*.yaml)
    echo "</tr>"
  done < <(find data/ -mindepth 1 -maxdepth 1 -type d)
  echo "</table>"

  __html_tail
}


__option2() {
  while read DIR; do
    if [[ -f "$DIR/ignore" ]]; then
      echo >&2 ":: $FUNCNAME: Ignore '$DIR'"
      continue
    fi

    SERVICE="$(basename $DIR)"
    {
      __html_head "${SERVICE}"
      ./woh.rb --option2 < <(cat "$DIR"/*.yaml)
      __html_tail
    } \
      > "$_D_OUTPUT/${SERVICE,,}.html"

    echo >&2 ":: '$_D_OUTPUT/${SERVICE,,}.html' has been updated."
  done < <(find data/ -mindepth 1 -maxdepth 1 -type d)
}


export _D_OUTPUT="${D_OUTPUT:-./output/}"

mkdir -pv "$_D_OUTPUT/"

__option1 > "$_D_OUTPUT/status.html"
echo >&2 ":: '$_D_OUTPUT/status.html' has been updated."

__option2
