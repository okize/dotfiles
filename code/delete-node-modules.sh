#!/bin/bash

# recursively delete node_modules directories
delete_node_modules() {
  for dir in "$1"/*; do
    if [[ -d "$dir" ]]; then
      if [[ "${dir##*/}" = "node_modules" ]]; then
        echo "* deleting $dir"
        rm -rf "$dir"
      else
        delete_node_modules "$dir"
      fi
    fi
  done
}

# prompt for root directory
read -p "enter the root directory: " root_dir

# ensure root directory exists
if [[ -d "$root_dir" ]]; then
  delete_node_modules "$root_dir"
  echo "node_modules directories deleted successfully."
else
  echo "invalid root directory!"
fi
