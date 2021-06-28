#!/bin/sh

# https://dchakarov.com/blog/macbook-remap-keys/
# remap caps lock key to ctrl
hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x7000000E0}]}'
