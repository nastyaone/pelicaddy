#!/bin/bash

set -e

clear

print_banner() {
  cat <<EOF

######################################################################################
#                                                                                    #
# Project 'PeliCaddy'                                                                #
#                                                                                    #
# Copyright (C) 2024, Nastya / NastyaOne, <connect@nastya.one>                       #
#                                                                                    #
#   This program is free software: you can redistribute it and/or modify             #
#   it under the terms of the GNU General Public License Version 3 as published by   #
#   the Free Software Foundation                                                     #
#                                                                                    #
#   This program is distributed in the hope that it will be useful,                  #
#   but WITHOUT ANY WARRANTY; without even the implied warranty of                   #
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                    #
#   GNU General Public License for more details.                                     #
#                                                                                    #
#   License information can be found at:                                             #
#   https://github.com/nastyaone/pelicaddy/blob/main/LICENSE                         #
#                                                                                    #
# https://github.com/nastyaone/pelicaddy                                             #
#                                                                                    #
# This script is an installer for https://pelican.dev/                               #
# It is not an official script.                                                      #
#                                                                                    #
# https://pelicaddy.nastya.one/                                                      #
#                                                                                    #
######################################################################################

EOF
}

print_banner

# Put "PeliCaddy:" for every console output
peli_caddy_echo() {
  echo "PeliCaddy: $1"
}

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  peli_caddy_echo "This script must be run as root. Please run with sudo or as root."
  exit 1
fi

# Display liability disclaimer and prompt for user consent
peli_caddy_echo "This is an unofficial script. Neither Nastya nor the Pelican Team takes any liability for any potential damage."
read -p "PeliCaddy: Do you understand and agree to proceed? (yes/no): " user_input

if [[ "$user_input" != "yes" ]]; then
  peli_caddy_echo "Exiting the script as per user request."
  exit 1
fi

# Detect the OS and version
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VERSION=$VERSION_ID
else
    peli_caddy_echo "Cannot detect the operating system. This script supports Debian 12, Ubuntu 22.04, Ubuntu 24.04, and Rocky Linux 9 only."
    exit 1
fi

# Determine if the OS is supported
if [[ "$OS" == "debian" && "$VERSION" == "12" ]]; then
    OS_TYPE=0
elif [[ "$OS" == "ubuntu" && ( "$VERSION" == "22.04" || "$VERSION" == "24.04" ) ]]; then
    OS_TYPE=1
elif [[ "$OS" == "rocky" && "$VERSION" == "9" ]]; then
    OS_TYPE=2
else
    peli_caddy_echo "Unsupported OS version: $OS $VERSION. This script supports Debian 12, Ubuntu 22.04, Ubuntu 24.04, and Rocky Linux 9 only."
    exit 1
fi

peli_caddy_echo "Detected OS: $OS $VERSION"

# Update and upgrade system
peli_caddy_echo "Updating and upgrading the system packages..."

if [[ "$OS_TYPE" == 0 || "$OS_TYPE" == 1 ]]; then
    apt update && apt upgrade -y
    peli_caddy_echo "System updated and upgraded on Debian/Ubuntu."
elif [[ "$OS_TYPE" == 2 ]]; then
    dnf upgrade -y
    peli_caddy_echo "System updated and upgraded on Rocky Linux."
else
    peli_caddy_echo "Unsupported OS. Exiting."
    exit 1
fi

clear

# Optionally clean up unnecessary packages (Debian/Ubuntu only)
if [[ "$OS_TYPE" == 0 || "$OS_TYPE" == 1 ]]; then
    peli_caddy_echo "There may be unused packages on your system. Would you like to remove them?"
    read -p "PeliCaddy: Run 'apt autoremove'? (yes/no): " cleanup_choice

    if [[ "$cleanup_choice" == "yes" ]]; then
        peli_caddy_echo "Running 'apt autoremove'..."
        apt autoremove -y
        peli_caddy_echo "Unused packages removed."
    else
        peli_caddy_echo "Skipping package cleanup."
    fi
else
    peli_caddy_echo "Package cleanup is only applicable to Debian/Ubuntu systems. Skipping."
fi
