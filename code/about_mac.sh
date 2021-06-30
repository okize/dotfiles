#!/usr/bin/env sh

#=======================================================
# CLI alternative to macOS's "About this Mac" feature.
#=======================================================

# lookup table for OS X marketing names
OSX_MARKETING_NAME=(
  ["0"]="Cheetah"
  ["1"]="Puma"
  ["2"]="Jaguar"
  ["3"]="Panther"
  ["4"]="Tiger"
  ["5"]="Leopard"
  ["6"]="Snow Leopard"
  ["7"]="Lion"
  ["8"]="Mountain Lion"
  ["9"]="Mavericks"
  ["10"]="Yosemite"
  ["11"]="El Capitan"
  ["12"]="Sierra"
  ["13"]="High Sierra"
  ["14"]="Mojave"
  ["15"]="Catalina"
)

# lookup table for macOS marketing names
MACOS_MARKETING_NAME=(
  ["11"]="Big Sur"
  ["12"]="Monterey"
)

OS_VER=$(sw_vers -productVersion)

# display a header message
write_header() {
  local name=$1; shift;
  printf "$name: $@\n"
}

# derrive Apple's marketing name for installed operating system
os_name () {
  local osx_number
  local os_type
  local os_version_major
  local os_version_minor
  local os_name

  os_version_major=$(echo $OS_VER | awk -F '[.]' '{print $1}')
  os_version_minor=$(echo $OS_VER | awk -F '[.]' '{print $2}')

  if [ $os_version_major == 10 ]
  then
    os_type="OS X"
    os_name="${OSX_MARKETING_NAME[$os_version_minor]}"
  else
    os_type="macOS"
    os_name="${MACOS_MARKETING_NAME[$os_version_major]}"
  fi

  printf "\n$os_type $os_name\n"
  echo "------------------------"
}

os_version () {
  write_header "VERSION" "$OS_VER"
}

hardware_model () {
  local hardware_mod
  hardware_mod=$(defaults read ~/Library/Preferences/com.apple.SystemProfiler.plist 'CPU Names' \
  | cut -sd '"' -f 4 \
  | uniq)

  write_header "HARDWARE" "$hardware_mod"
}

processor () {
  local cpu
  cpu=$(system_profiler SPHardwareDataType \
  | awk '/Processor (Name|Speed):/ { sub(/^.*: /, ""); print; }'\
  | sort \
  | xargs)

  write_header "PROCESSOR" "$cpu"
}

memory () {
  local ram
  ram=$(
  awk '
    $1~/Size/ && $2!~/Empty/ {size+=$2}
    $1~/Speed/ && $2!~/Empty/ {speed=$2" "$3}
    $1~/Type/ && $2!~/Empty/ {type=$2}
    END {print size " GB " speed " " type}
    ' <<< "$(system_profiler SPHardwareDataType; system_profiler SPMemoryDataType)"
)

  write_header "MEMORY" "${ram}"
}

startup_disk () {
  local disk
  disk=$(system_profiler SPStorageDataType \
  | awk 'FNR == 3 {print}'\
  | sed 's/[[:blank:]:]*//g')

  write_header "STARTUP DISK" "$disk"
}

graphics () {
  local gpu
  gpu=$(system_profiler SPDisplaysDataType \
  | awk '/(Model|Max\)|Total\)):/ { sub(/^.*: /, ""); print; }' \
  | xargs)

  write_header "GRAPHICS" "$gpu"
}

serial_number () {
  local serialnum
  serialnum=$(system_profiler SPHardwareDataType \
  | awk '/Serial/ { sub(/^.*: /, ""); print; }')

  write_header "SERIAL NUMBER" "$serialnum"
}

# order here will also be display order
main () {
  os_name
  os_version
  hardware_model
  processor
  memory
  startup_disk
  graphics
  serial_number
}

main "$@"
