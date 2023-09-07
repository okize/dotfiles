#!/usr/bin/env sh

#=======================================================
# CLI alternative to macOS's "About this Mac" feature.
#=======================================================

# display a header message
write_header() {
  local NAME=$1; shift;
  printf "$NAME: $@\n"
}

# either "macOS" or "Mac OS X"
OS_TYPE=$(sw_vers -productName)
OS_VERSION=$(sw_vers -productVersion)
OS_BUILD=$(sw_vers -buildVersion)

# derrive Apple's product name for installed operating system and assign it to OS_PRODUCT_NAME
os_product_name () {
  if [ "$OS_TYPE" == "macOS" ]
  then
    OS_PRODUCT_NAME="macOS"
  else
    OS_PRODUCT_NAME="OS X"
  fi
}

# derrive Apple's marketing name for installed operating system and assign it to OS_MARKETING_NAME
os_marketing_name () {
  local MACOS_MARKETING_NAME
  local OSX_MARKETING_NAME
  local OS_VERSION_MAJOR
  local OS_VERSION_MINOR

  # lookup table for macOS marketing names
  MACOS_MARKETING_NAME=(
    ["11"]="Big Sur"
    ["12"]="Monterey"
    ["13"]="Ventura"
  )

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

  OS_VERSION_MAJOR=$(echo $OS_VERSION | awk -F '[.]' '{print $1}')
  OS_VERSION_MINOR=$(echo $OS_VERSION | awk -F '[.]' '{print $2}')

  if [ "$OS_TYPE" == "macOS" ]
  then
    OS_MARKETING_NAME="${MACOS_MARKETING_NAME[$OS_VERSION_MAJOR]}"
  else
    OS_MARKETING_NAME="${OSX_MARKETING_NAME[$OS_VERSION_MINOR]}"
  fi
}

os_details () {
  os_product_name
  os_marketing_name

  printf "\n$OS_PRODUCT_NAME | $OS_MARKETING_NAME ($OS_VERSION)\n"
  echo "------------------------"
}

hardware_model () {
  local HARDWARE_MOD
  HARDWARE_MOD=$(defaults read ~/Library/Preferences/com.apple.SystemProfiler.plist 'CPU Names' \
  | cut -sd '"' -f 4 \
  | uniq)

  write_header "HARDWARE" "$HARDWARE_MOD"
}

processor () {
  local CPU
  CPU=$(system_profiler SPHardwareDataType \
  | awk '/Processor (Name|Speed):/ { sub(/^.*: /, ""); print; }'\
  | sort \
  | xargs)

  write_header "PROCESSOR" "$CPU"
}

memory () {
  local RAM
  RAM=$(
  awk '
    $1~/Size/ && $2!~/Empty/ {size+=$2}
    $1~/Speed/ && $2!~/Empty/ {speed=$2" "$3}
    $1~/Type/ && $2!~/Empty/ {type=$2}
    END {print size " GB " speed " " type}
    ' <<< "$(system_profiler SPHardwareDataType; system_profiler SPMemoryDataType)"
)

  write_header "MEMORY" "${RAM}"
}

startup_disk () {
  local DISK
  DISK=$(system_profiler SPStorageDataType \
  | awk 'FNR == 3 {print}'\
  | sed 's/[[:blank:]:]*//g')

  write_header "STARTUP DISK" "$DISK"
}

graphics () {
  local GPU
  GPU=$(system_profiler SPDisplaysDataType \
  | awk '/(Model|Max\)|Total\)):/ { sub(/^.*: /, ""); print; }' \
  | xargs)

  write_header "GRAPHICS" "$GPU"
}

serial_number () {
  local SERIALNUM
  SERIALNUM=$(system_profiler SPHardwareDataType \
  | awk '/Serial/ { sub(/^.*: /, ""); print; }')

  write_header "SERIAL NUMBER" "$SERIALNUM"
}

# order here will also be display order
main () {
  os_details
  hardware_model
  processor
  memory
  startup_disk
  graphics
  serial_number
}

main "$@"
