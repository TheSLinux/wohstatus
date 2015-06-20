#!/bin/bash

./check.sh
./compile.sh
rsync -rapv --delete ./output/ $HOME/public_html/wohstatus/
cd $HOME/public_html/wohstatus/
ln -s status.html index.html
