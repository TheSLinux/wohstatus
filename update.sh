#!/bin/bash

./check.sh
./compile.sh

mkdir -pv output/api/
./api.sh /status > ./output/api/status.yaml

rsync -rapv --delete ./output/ $HOME/public_html/wohstatus/
cd $HOME/public_html/wohstatus/
ln -s status.html index.html
