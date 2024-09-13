#!/bin/bash

#Assign Variables
TOKEN="<SITE_TOKEN-HERE>"
Rpm86="S1x86.rpm"
Deb86="S1x86.deb"
RpmAarch="S1aarch.rpm"
DebAarch="S1aarch.deb"

# Determine Package Handler
if which rpm > /dev/null 2>&1; then
  # If rpm is installed, assign rpm to PkgMgr
  PkgMgr="rpm"
elif which dpkg > /dev/null 2>&1; then
  # If dpkg is installed, assign dpkg to PkgMgr
  PkgMgr="dpkg"
else
  # If neither is installed, assign unknown to PkgMgr
  PkgMgr="unknown"
fi

#Determine system architecture
SysType="uname -m"

# Change to the directory where the script is located
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$script_dir"

##Create tmp/WorkDir folder and copy contents of iso to it
dirName='/tmp/WorkDir'
if [ -d "$dirName" ]; then
  rm -rf "$dirName"
fi
mkdir "$dirName"
cp * /tmp/WorkDir/

##Change working directories
cd /tmp/WorkDir/

##Check OS version and determine install package
if [[ "$PkgMgr" == *"rpm"* ]] && [[ "$SysType" == *"86"* ]]; then
  chmod +x "$Rpm86"
  rpm -i "$Rpm86"
elif [[ "$PkgMgr" == *"dpkg"* ]] && [[ "$SysType" == *"86"* ]]; then
  chmod +x "$Deb86"
  rpm -i "$Deb86"
elif [[ "$PkgMgr" == *"rpm"* ]] && [[ "$SysType" == *"arch"* ]]; then
  chmod +x "$RpmAarch"
  rpm -i "$RpmAarch"
elif [[ "$PkgMgr" == *"dpkg"* ]] && [[ "$SysType" == *"arch"* ]]; then
  chmod +x "$DebAarch"
  rpm -i "$DebAarch"
else
  echo "Install manually for $SysType with $PkgMgr"
  return
fi

# Check the return code for success
if [ $? -ne 0 ]; then
  echo "Error: Failed to install the package."
  exit 1
fi

#Set Token
/opt/sentinelone/bin/sentinelctl management token set $TOKEN

#Start Agent
/opt/sentinelone/bin/sentinelctl control start

#Verify running
ps -e | grep falcon-sensor

exit 0
