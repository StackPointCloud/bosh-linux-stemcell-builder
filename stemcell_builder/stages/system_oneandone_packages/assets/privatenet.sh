#!/bin/bash

echo "Private network begin"
metadata_urlbase="http://169.254.169.254/latest/meta_data/interfaces/private/"
for interface_id in $(curl -fs ${metadata_urlbase})
do
    interface_hwaddr=$(curl -fs ${metadata_urlbase}${interface_id}mac)
    interface_ipaddr=$(curl -fs ${metadata_urlbase}${interface_id}ipv4/0/ip_address)
    interface_netmask=$(curl -fs ${metadata_urlbase}${interface_id}ipv4/0/netmask)
    interface_device=$(ip link show | awk '($1 ~ /^.+:$/) {gsub(/:$/,"",$2); device=$2; getline; if (tolower($2) == tolower("'${interface_hwaddr}'")) {print device}}')
    echo "Working on interfaces/private/${interface_id} (mac: ${interface_hwaddr} ip: ${interface_ipaddr} mask: ${interface_netmask} device: ${interface_device})"
    if [ -n "${interface_ipaddr}" -a -n "${interface_netmask}" -a -n "${interface_device}" ]
    then
        if ! grep -q "^source /etc/network/interfaces.d/*" /etc/network/interfaces ; then
            echo "source /etc/network/interfaces.d/*" >>/etc/network/interfaces
        fi
        mkdir -p /etc/network/interfaces.d/ || true
        cat <<EOF_FILE >/etc/network/interfaces.d/${interface_device}.cfg
auto ${interface_device}
    iface ${interface_device} inet static
        address ${interface_ipaddr}
        netmask ${interface_netmask}
        hwaddress ${interface_hwaddr}
EOF_FILE
        ifup ${interface_device}
    fi
done
echo "Private network end"