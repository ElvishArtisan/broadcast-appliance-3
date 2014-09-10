#!/bin/sh

# build_iso.sh
#
# (C) Copyright 2010-2014 Fred Gleason <fredg@paravelsystems.com>
#
# Build a custom CentOS ISO
#
# The following CentOS 7 packages are required:
#   createrepo
#   isomd5sum
#

USAGE="build_iso.sh <target-iso> [burn]"

if [ -z $1 ] ; then
  echo $USAGE
  exit 256
fi

#
# Arguments
#
TARGET_ISO=$1
BURN_FLAG=$2

#
# Site Defines
#
APPLIANCE_ROOT=/root/ba/centos7/x86_64
APPLICATION_ID="Rivendell"
PUBLISHER_ID="ParavelSystems"

#
# Check Manifest
#
./check_manifest.sh
if test $? -ne 0 ; then
  echo "Failed manifest check, exiting..."
  echo
  exit 256
fi

#
# Clean Tree
#
find $APPLIANCE_ROOT -name \*~ -exec rm \{\} \;
find $APPLIANCE_ROOT -name TRANS.TBL -exec rm \{\} \;
rm -rf $APPLIANCE_ROOT/isolinux/repodata

#
# Display CD Burn Status
#
if [ -z $BURN_FLAG ] ; then
  echo "CD burn stage will be skipped!"
else
  echo "CD will be burned, ensure that blank CD media is in drive"
fi
echo

#
# Create Repository Data
#
echo "Creating repository data."
createrepo -g $APPLIANCE_ROOT/comps.xml $APPLIANCE_ROOT/isolinux/
echo

#
# Create ISO
#
echo "Generating ISO data."
mkisofs -o $TARGET_ISO -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -V 'CentOS 7 x86_64' -A $APPLICATION_ID -publisher $PUBLISHER_ID -R -J -v -T $APPLIANCE_ROOT/isolinux/
implantisomd5 $TARGET_ISO
echo

#
# Burn CD
#
if [ -z $BURN_FLAG ] ; then
  echo "ISO complete!"
  exit 0
fi
echo "Starting CD burn."
wodim -v -eject $TARGET_ISO
#cdrecord dev=1,0,0 $TARGET_ISO
#growisofs -dvd-compat -Z /dev/dvd=$TARGET_ISO
echo
echo "ISO and CD burn complete!"
