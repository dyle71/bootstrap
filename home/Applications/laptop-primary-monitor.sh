#!/usr/bin/env bash

PRIMARY_OUTPUT="eDP-1"
kscreen-doctor \
  output.$PRIMARY_OUTPUT.enable \
  output.$PRIMARY_OUTPUT.primary \
  output.$PRIMARY_OUTPUT.position.0,0

