#!/bin/bash

# Purpose: Add new event to `wohstatus` database
# Author : Anh K. Huynh
# License: MIT license

_D_OUTPUT="${D_OUTPUT:-./output/}"
_DATABASE="${1:-}"; shift
_STATUS="${1:-}"; shift
_MESSAGE="${@}"
_FYAML="$_DATABASE/${WOHSTATUS_OUTPUT:-$(date +%Y)}.yaml"

if [[ -z "$_MESSAGE" ]]; then
  echo >&2 ":: Syntax: $0 <database dir> <status> <message>"
  exit 1
fi

if [[ ! -d "$_DATABASE" ]]; then
  echo >&2 ":: Directory not found '$_DATABASE'"
  exit 1
fi

if [[ ! -f "${_D_OUTPUT}/images/$_STATUS.png" ]]; then
  echo >&2 ":: Image not found '${_D_OUTPUT}/images/$_STATUS.png'"
  echo >&2 ":: Status is not valid."
  exit 1
fi

_FTEMP="$(mktemp)"
if [[ $? -ge 1 ]]; then
  echo >&2 ":: Unable to create temporary file"
  exit 1
fi

touch "$_FYAML"

export WOHSTATUS_SYMBOL="$_STATUS"
export WOHSTATUS_MESSAGE="$_MESSAGE"

ruby \
    > "$_FTEMP" \
    < "$_FYAML" \
  -ryaml \
  -rtime \
  -e '
    data = YAML.load(STDIN.read)
    data ||= {}
    data["events"] ||= {}

    status = ENV["WOHSTATUS_SYMBOL"]
    message = ENV["WOHSTATUS_MESSAGE"]

    data["events"][DateTime.parse(Time.now.to_s).rfc2822] = {"status" => status, "message" => message}
    puts YAML.dump(data)
  '

which diff >/dev/null 2>&1 \
&& diff "$_FYAML" "$_FTEMP" \
|| true
mv -iv "$_FTEMP" "$_FYAML"

if [[ -f "$_FTEMP" ]]; then
  rm -fv "$_FTEMP"
fi
