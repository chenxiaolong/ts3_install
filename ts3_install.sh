#!/usr/bin/env bash
# Version 1.0.0
# Licensed under MIT
# https://github.com/IAreKyleW00t/ts3install/
# Copyright (c) 2015 Kyle Colantonio <kyle10468@gmail.com>

# Exit on error. Append ||true if you expect an error.
set -o errexit
set -o nounset

# Bash will remember & return the highest exitcode in a chain of pipes.
set -o pipefail

# Global variables
TS_TAR="teamspeak3-server_linux-amd64-3.0.11.4.tar.gz"
TS_DL="http://dl.4players.de/ts/releases/3.0.11.4/teamspeak3-server_linux-amd64-3.0.11.4.tar.gz"
TS_DIR="/usr/local/teamspeak3"
TS_MD5="53eb064c9139f4bfb22fd29c07380730"
TS_USR="teamspeak"
TMP="/tmp/teamspeak3"

# Color variables
NORM='\033[0m'
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'

# Check if script was ran as root.
if [[ $EUID -ne 0 ]]; then
    printf "${RED}This script must be ran as root.${NORM}\n"
    exit 1
fi

# Display header
printf "+-----------------------------------------+\n"
printf "|    TeamSpeak 3 Server Install Script    |\n"
printf "|           By: Kyle Colantonio           |\n"
printf "|              Version 1.0.0              |\n"
printf "+----------------------------------------+\n"
printf "\n"
printf "       ${RED}WARNING!! WARNING!! WARNING!!${NORM}\n"
printf "This script is designed for ${CYAN}NEW${NORM} installations\n"
printf "of a TeamSpeak 3 Server. ${RED}DO NOT${NORM} attempt to\n"
printf "use this script if you already have an existing\n"
printf "TS3 Server installed. You have been warned!\n\n"

# Prompt user to continue
read -r -p "Continue? [y/N] " -i "N" response
response=${response,,} # toLowerCase
if [[ ! $response =~ ^(yes|y)$ ]]; then # if NOT yes
    exit 1
fi
printf "\n"

# Create temp folder
mkdir -p "${TMP}"

# Download TeamSpeak 3 Server tar
printf "[1] Downloading TeamSpeak 3 Server..."
if [[ -f "${TMP}/${TS_TAR}" ]]; then
    # If the file exists, delete it
    rm "${TMP}/${TS_TAR}"
fi
curl -s "${TS_DL}" -o "${TMP}/${TS_TAR}"
printf " ${GREEN}DONE!${NORM}\n"

# Check Download MD5
printf "    > Checking MD5..."
if [[ $(md5sum "${TMP}/${TS_TAR}" | cut -d ' ' -f 1) = "${TS_MD5}" ]]; then
    printf " ${GREEN}OK!${NORM}\n"
else
    # MD5 doesn't match
    printf " ${RED}ERROR!${NORM}\n\n"
    printf "MD5 did not match expected value... Please try again.\n"
    rm -rf "${TMP}"
    exit 1
fi

# Install TeamSpeak 3 Server
printf "[2] Installing TeamSpeak 3 Server...\n"
if [[ -f "${TS_DIR}" ]]; then
    # Delete the install folder if it already exists
    rm -rf "${TS_DIR}"
fi
mkdir -p "${TS_DIR}"
printf "    > Extracting..."
tar -xf "${TMP}/${TS_TAR}" -C "${TS_DIR}" --strip-components=1
printf " ${GREEN}DONE!${NORM}\n"
printf "    > Installing Service..."
ln -s "${TS_DIR}/ts3server_startscript.sh" "/etc/init.d/teamspeak"
update-rc.d teamspeak defaults &> /dev/null
printf " ${GREEN}DONE!${NORM}\n"

# Create 'teamspeak' user
printf "[4] Creating '${TS_USR}' System User..."
if [[ $(getent passwd "${TS_USR}" 2>&1 && true) ]]; then
    # Remove any pre-existing teamspeak user
    userdel teamspeak
fi
useradd -M -r -s "/bin/false" -c "TeamSpeak 3 system user" "${TS_USR}"
printf " ${GREEN}DONE!${NORM}\n"

# Update Permissions
printf "    > Updating permissions..."
chown -R "${TS_USR}:${TS_USR}" "${TS_DIR}"
printf " ${GREEN}DONE!${NORM}\n"

# Update IPTables
printf "[5] Updating iptables..."
iptables -A INPUT -p udp --dport 9987 -j ACCEPT
iptables -A INPUT -p udp --sport 9987 -j ACCEPT
iptables -A INPUT -p tcp --dport 30033 -j ACCEPT
iptables -A INPUT -p tcp --sport 30033 -j ACCEPT
iptables -A INPUT -p tcp --dport 10011 -j ACCEPT
iptables -A INPUT -p tcp --sport 10011 -j ACCEPT
printf " ${GREEN}DONE!${NORM}\n"

# Cleanup
printf "[6] Cleaning up..."
rm -rf "${TMP}"
printf " ${GREEN}DONE!${NORM}\n\n"

printf "All done! You can start your server using \`service teamspeak start\`!\n"
exit 0