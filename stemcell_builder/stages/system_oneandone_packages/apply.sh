#!/usr/bin/env bash
# -*- encoding: utf-8 -*-

set -e

base_dir=$(readlink -nf $(dirname $0)/../..)
source $base_dir/lib/prelude_apply.bash

run_in_chroot $chroot "apt-get update"
run_in_chroot $chroot "apt-get -y install cloud-init --no-install-recommends"

if [ -e "$chroot/usr/lib/python3/dist-packages/cloudinit" ]; then # ubuntu xenial 16.04
cp  $assets_dir/DataSourceUI.py $chroot/usr/lib/python3/dist-packages/cloudinit/sources/
cp -R $assets_dir/cloud/ $chroot/etc/

elif [ -e "$chroot/usr/lib/python2.7/dist-packages/cloudinit" ]; then # ubuntu trust 14.04
cp  $assets_dir/DataSourceUI.py $chroot/usr/lib/python2.7/dist-packages/cloudinit/sources/
cp -R $assets_dir/cloud/ $chroot/etc/

fi
