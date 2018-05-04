#!/usr/bin/env bash
#
# Copyright (c) 2009-2012 VMware, Inc.

set -e

base_dir=$(readlink -nf $(dirname $0)/../..)
source $base_dir/lib/prelude_apply.bash

sed "/^ *PermitRootLogin/d" -i $chroot/etc/ssh/sshd_config
echo 'PermitRootLogin yes' >> $chroot/etc/ssh/sshd_config

sed "/^ *AllowGroups/d" -i $chroot/etc/ssh/sshd_config
echo 'AllowGroups bosh_sshers root' >> $chroot/etc/ssh/sshd_config

echo 'AllowUsers vcap root' >> $chroot/etc/ssh/sshd_config

sed "/^ *DenyUsers/d" -i $chroot/etc/ssh/sshd_config

sed "/^ *PasswordAuthentication/d" -i $chroot/etc/ssh/sshd_config
echo 'PasswordAuthentication no' >> $chroot/etc/ssh/sshd_config