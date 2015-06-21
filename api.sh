#!/bin/bash

# Purpose: A simpel API to interact with `wohstatus` database
# Author : Anh K. Huynh
# License: MIT license

_get_status() {
  echo "---"
  echo "error_code: 500"

  while read DIR; do
    if [[ ! -d "$DIR" ]]; then
      echo >&2 ":: $FUNCNAME: Directory not found '$DIR'"
      continue
    fi
    if [[ -f "$DIR/ignore" ]]; then
      echo >&2 ":: $FUNCNAME: Directory ignored '$DIR'"
      continue
    fi
    last_status="$(./woh.rb --option3 < <(cat "$DIR/"*.yaml ))"
    last_code="$(echo $last_status | awk '{print $1}')"
    last_message="${last_status:$((${#last_code}+1))}"
    echo "\"$(basename $DIR)\":"
    echo "  status: $last_code"
    echo "  message: $last_message"
  done < <(find "./data/" -mindepth 1 -maxdepth 1 -type d )

  echo "error_code: 200"
}

########################################################################
# Main proram
########################################################################

case "${1:-}" in
  "/status") _get_status ;;
  *)
    echo "---"
    echo "error_code: 403"
    echo "error_message: Unknown method"
    ;;
esac
