#!/usr/bin/env zsh

# https://dchakarov.com/blog/macbook-remap-keys/
# https://blog.codefront.net/2020/06/24/remapping-keys-on-macos
# remap caps lock key to ctrl
hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x7000000E0}]}'
