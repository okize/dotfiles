#!/usr/bin/env sh
# mjk 2018.07.09

#=======================================================
#  CLI alternative to OS X's "About this Mac" feature.
#  retrieve information about: OS X "marketing" name;
#  OS version number; hardware model; processor; memory;
#  startup disk; graphics; and serial number.
#=======================================================

#==========================================================
# This script frequently calls
# OS X's system_profiler to poll a data type, e.g.:
# system_profiler SP_Some_DataType \
# | awk '/string_to_extract/{ sub(/^.*: /, ""); print; }')
# where the output of the profiler is piped to `awk`;
# a search string is extracted;
# and characters to the right of `:` are printed
#==========================================================

# lookup table for OS X marketing names
MARKETING_NAME=(
["1010"]="Yosemite"
["1011"]="El Capitan"
["1012"]="Sierra"
["1013"]="High Sierra"
["1014"]="Mojave"
["1015"]="Catalina"
)

# display header message
write_header() {
  local name=$1; shift;
  printf "%s\\n""--------------------\\n$name%s\\n--------------------\\n"
  printf "%s\\n" "$@"
}

# retrieve Apple's marketing name for installed operating system
osx_name () {
  local osx_number
  osx_number=$(sw_vers -productVersion| awk -F '[.]' '{print $1$2}')

  if [[ -n "${MARKETING_NAME[$osx_number]}" ]]; then
    local osx_name
    osx_name="${MARKETING_NAME[$osx_number]}"
fi

  write_header "OS X Name" "$osx_name"
}

# retrieve operating system version
operating_system () {
  local os
  os=$(sw_vers -productVersion)

  write_header "OS Version" "$os"
}

# retrieve hardware model
hardware_model () {
  local hardware_mod
  hardware_mod=$(defaults read ~/Library/Preferences/com.apple.SystemProfiler.plist 'CPU Names' \
  | cut -sd '"' -f 4 \
  | uniq)

  write_header "Hardware Model" "$hardware_mod"
}

# retrieve processor information

processor () {
  local cpu
  cpu=$(system_profiler SPHardwareDataType \
  | awk '/Processor (Name|Speed):/ { sub(/^.*: /, ""); print; }'\
  | sort \
  | xargs)

  write_header "Processor" "$cpu"
}

# retrieve memory information
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

  write_header "Memory" "${ram}"
}

# retrieve startup disk information
startup_disk () {
  local disk
  disk=$(system_profiler SPStorageDataType \
  | awk 'FNR == 3 {print}'\
  | sed 's/[[:blank:]:]*//g')

  write_header "Startup Disk" "$disk"
}

# retrieve graphics information
graphics () {
  local gpu
  gpu=$(system_profiler SPDisplaysDataType \
  | awk '/(Model|Max\)|Total\)):/ { sub(/^.*: /, ""); print; }' \
  | xargs)

  write_header "Graphics" "$gpu"
}

# retrieve serial number
serial_number () {
  local serialnum
  serialnum=$(system_profiler SPHardwareDataType \
  | awk '/Serial/ { sub(/^.*: /, ""); print; }')

  write_header "Serial Number" "$serialnum"
}

main () {
  osx_name
  operating_system
  hardware_model
  processor
  memory
  startup_disk
  graphics
  serial_number
}

main "$@"
