#!/usr/bin/env bash

# go install github.com/openvex/vexctl@latest
jq ".packages[].location" index.json | \
  xargs ~/go/bin/vexctl merge --author "agologan@users.noreply.github.com" | \
  jq '.statements |= sort_by(.vulnerability["@id"])' | \
  jq '.statements[] |= del(.timestamp)' > merged.openvex.json
