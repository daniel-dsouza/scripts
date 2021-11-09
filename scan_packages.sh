#!/usr/bin/env bash

DISTRO=$(lsb_release -cs)
PACKAGES=$(dpkg --get-selections | grep -v "deinstall" | cut -f1)

echo "scanning "$(echo $PACKAGES | wc -w) "total pacakges."

for package in $PACKAGES
do
  if test $(echo $package | grep -c -e "^lib") -eq 1
  then
    continue
  fi

  POLICY=$(apt-cache policy $package)
  RES=$(echo $POLICY | grep -c -e "$DISTRO-security/main" -e "$DISTRO-updates/main" -e "$DISTRO/main")
  # echo "scanning" $package $RES
  if test $RES -eq 1 
  then
    continue
  fi

  RES2=$(echo $POLICY | grep -c -e "$DISTRO/universe" -e "$DISTRO-security/universe" -e "$DISTRO-updates/universe")
  if test $RES2 -eq 1
  then
    ORIG_MAINTAINED_BY_DEBIAN=$(apt-cache show $package | grep -e ^"Original-Maintainer".*."debian.org" -c)
    MAINTAINED_BY_UBUNTU_DEBIAN=$(apt-cache show $package | grep -e ^"Maintainer".*."ubuntu.com" -e ^"Maintainer".*."debian.org" -c)

    # echo $package":" $ORIG_MAINTAINED_BY_DEBIAN $MAINTAINED_BY_UBUNTU_DEBIAN
    if [ $ORIG_MAINTAINED_BY_DEBIAN -ge 1 ] || [ $MAINTAINED_BY_UBUNTU_DEBIAN -ge 1 ]
    then
      # echo $package": OK"
      continue
    fi

    echo $package": in universe and not imported from debian"
  fi

  echo $package "potentially not maintained"
done
  
