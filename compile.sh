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
  <head>
  <title>${WOHSTATUS_TITLE:-WohStatus}${_subtitle}</title>
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
    word-wrap: break-word;
    max-width: 400px;
  }
  td.message {
    width: 400px;
  }
  td.status {
    width: 64px;
    text-align: center;
  }
  td.status_thin {
    padding: 10px;
    text-align: center;
  }
  td.service {
    text-align: center;
  }
  img.icon {
    width: 16px;
    height: 16px;
  }

  #legend td {
    padding: 5px;
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
<table id="legend">
  <tr>
    <td class="status_thin"><img class="icon" src="./images/up.png" /></td>
    <td class="message">Service is up and running</td>
  </tr>
  <tr>
    <td class="status_thin"><img class="icon" src="./images/down.png" /></td>
    <td class="message">Service is down</td>
  </tr>
  <tr>
    <td class="status_thin"><img class="icon" src="./images/limited.png" /></td>
    <td class="message">Service is running but has limited function</td>
  </tr>
  <tr>
    <td class="status_thin"><img class="icon" src="./images/maintenance.png" /></td>
    <td class="message">Service is being maintained</td>
  </tr>
  <tr>
    <td class="status_thin"><img class="icon" src="./images/bug.png" /></td>
    <td class="message">Unknown status</td>
  </tr>
  <tr>
    <td class="status_thin"><img class="icon" src="./images/info.png" /></td>
    <td class="message">Information</td>
  </tr>
</table>

<h3><a href="https://github.com/icy/wohstatus">Powered by <em>WohStatus</em></a></h3>
<h3><a href="https://github.com/twilio/stashboard">Icons come from Stashboard</a></h3>
</body>
</html>
EOF

}

# Print status information for all services
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
    if [[ ! -d "$DIR/" ]]; then
      echo >&2 ":: $FUNCNAME: Directory not found '$DIR'"
      continue
    fi
    if [[ -f "$DIR/ignore" ]]; then
      echo >&2 ":: $FUNCNAME: Ignore '$DIR'"
      continue
    fi
    export SERVICE="$(basename $DIR)"
    echo "<tr>"
    ./woh.rb --option1 < <(cat "$DIR"/*.yaml)
    echo "</tr>"
  done \
  < <(
    {
      [[ ! -f data/sort ]] || cat data/sort
      find data/ -mindepth 1 -maxdepth 1 -type d
    } \
    | awk '!count[$0]++'
  )

  echo "</table>"

  __html_tail
}


# Print status information for a specific service
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
