#!/bin/sh

# check_manifest.sh
#
# Check the current state of the package repository against the manifest
#
# (C) Copyright 2014 Fred Gleason <fredg@paravelsystems.com>
#

ls isolinux/Packages/* > MANIFEST.tmp
diff -u --recursive --new-file MANIFEST MANIFEST.tmp > MANIFEST.diff

if test -f MANIFEST.diff -a ! -s MANIFEST.diff ; then
  rm -f MANIFEST.diff MANIFEST.tmp
  exit 0
fi

echo "Package repository does not match manifest!"
echo
cat MANIFEST.diff
rm -f MANIFEST.diff MANIFEST.tmp
echo

exit 127

