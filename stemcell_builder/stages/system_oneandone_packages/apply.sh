#!/usr/bin/env bash
# -*- encoding: utf-8 -*-

set -e

base_dir=$(readlink -nf $(dirname $0)/../..)
source $base_dir/lib/prelude_apply.bash

run_in_chroot $chroot "apt-get update"
run_in_chroot $chroot "apt-get -y install cloud-init --no-install-recommends"

cp  $assets_dir/DataSourceUI.py $chroot/usr/lib/python3/dist-packages/cloudinit/sources/
cp -R $assets_dir/cloud/ $chroot/etc/
