#!/bin/sh

dotnetDir="/opt/dotnet"

if [ -d "/etc/dns/config" ]
then
    dnsDir="/etc/dns"
else
    dnsDir="/opt/technitium/dns"
fi

dnsConfig="/etc/dns"

echo ""
echo "================================="
echo "Technitium DNS Server Uninstaller"
echo "================================="
echo ""
echo "Uninstalling Technitium DNS Server..."

if [ -d $dnsDir ]
then
    if [ "$(ps --no-headers -o comm 1 | tr -d '\n')" = "systemd" ] 
    then
        systemctl disable dns.service >/dev/null 2>&1
        systemctl stop dns.service >/dev/null 2>&1
        rm /etc/systemd/system/dns.service >/dev/null 2>&1

        rm /etc/resolv.conf >/dev/null 2>&1

        if [ -f "$dnsDir/resolv.conf.bak" ] || [ -L "$dnsDir/resolv.conf.bak" ]
        then
            cp -a $dnsDir/resolv.conf.bak /etc/resolv.conf >/dev/null 2>&1
        else
            echo "nameserver 8.8.8.8" >> /etc/resolv.conf
            echo "nameserver 1.1.1.1" >> /etc/resolv.conf
        fi

        if [ -f "/etc/NetworkManager/NetworkManager.conf" ]
        then
            currentVal=$(grep -F "dns=" /etc/NetworkManager/NetworkManager.conf)

            if [ "$currentVal" = "dns=none" ]
            then
                sed -i "s/$currentVal/dns=default/g" /etc/NetworkManager/NetworkManager.conf >/dev/null 2>&1
            fi
        fi

        systemctl enable systemd-resolved >/dev/null 2>&1
        systemctl start systemd-resolved >/dev/null 2>&1
    fi

    rm -rf $dnsDir >/dev/null 2>&1

    if [ -d $dotnetDir ]
    then
        echo "Uninstalling .NET Runtime..."
        rm /usr/bin/dotnet >/dev/null 2>&1
        rm -rf $dotnetDir >/dev/null 2>&1
    fi

    if [ -d "$dnsConfig" ]
    then
        echo ""
        printf "Do you want to delete the config folder at '$dnsConfig' which contains all of the DNS server config files? (y/N): "
        read -r answer

        case "$answer" in
            [Yy]* )
                rm -rf "$dnsConfig" >/dev/null 2>&1
                echo "The '$dnsConfig' config folder was deleted successfully."
                ;;
            * )
                echo "The '$dnsConfig' config folder was not deleted and it will be reused if you install the DNS server again."
                ;;
        esac
    fi
fi

echo ""
echo "Thank you for using Technitium DNS Server!"
echo ""
