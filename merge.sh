#!/usr/bin/env bash

jq ".packages[].location" index.json | xargs ~/go/bin/vexctl merge --author "agologan@users.noreply.github.com" > merged.openvex.json
