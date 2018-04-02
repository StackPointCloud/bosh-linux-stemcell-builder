#!/usr/bin/env bash

base_dir=$(readlink -nf $(dirname $0)/../..)
source $base_dir/lib/prelude_apply.bash
source $base_dir/lib/prelude_agent.bash

cat > $chroot/var/vcap/bosh/agent.json <<JSON
{
  "Platform": {
    "Linux": {
      "UseDefaultTmpDir": true,
      "SkipDiskSetup": true
    }
  },
   "Infrastructure": {
     "Settings": {
       "Sources": [
         {
           "Type": "File",
           "MetaDataPath": "",
           "UserDataPath": "/var/vcap/bosh/user_data.json",
           "SettingsPath": "/var/vcap/bosh/user_data.json"
         }
       ]
     }
   }
 }
JSON
