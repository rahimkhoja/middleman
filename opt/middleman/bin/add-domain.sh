#!/bin/bash
# Add New Domain to The Middle Man. This includes CertBot SSL Certificate Setup, Varnish Configureation, and PageSpeed Module.
# By Rahim Khoja (rahim.khoja@alumni.ubc.ca)
# https://www.linkedin.com/in/rahim-khoja-879944139/

echo
echo -e "\033[0;31m░░░░░░░░▀▀▀██████▄▄▄"
echo "░░░░░░▄▄▄▄▄░░█████████▄ "
echo "░░░░░▀▀▀▀█████▌░▀▐▄░▀▐█ "
echo "░░░▀▀█████▄▄░▀██████▄██ "
echo "░░░▀▄▄▄▄▄░░▀▀█▄▀█════█▀"
echo "░░░░░░░░▀▀▀▄░░▀▀███░▀░░░░░░▄▄"
echo "░░░░░▄███▀▀██▄████████▄░▄▀▀▀██▌"
echo "░░░██▀▄▄▄██▀▄███▀▀▀▀████░░░░░▀█▄"
echo "▄▀▀▀▄██▄▀▀▌█████████████░░░░▌▄▄▀"
echo "▌░░░░▐▀████▐███████████▌"
echo "▀▄░░▄▀░░░▀▀██████████▀"
echo "░░▀▀░░░░░░▀▀█████████▀"
echo "░░░░░░░░▄▄██▀██████▀█"
echo "░░░░░░▄██▀░░░░░▀▀▀░░█"
echo "░░░░░▄█░░░░░░░░░░░░░▐▌"
echo "░▄▄▄▄█▌░░░░░░░░░░░░░░▀█▄▄▄▄▀▀▄"
echo -e "▌░░░░░▐░░░░░░░░░░░░░░░░▀▀▄▄▄▀\033[0m"
echo "---The Middle Man - Website Caching & Optimizing System - Add Domain Script---"
echo "---By: Rahim Khoja (rahim.khoja@alumni.ubc.ca)---"
echo

# Default Variables
defaulthn="example.local"
defaultproxy="http://10.10.10.10:8080/"
adddomain="0"
finish="-1"

# Check the bash shell script is being run by root
if [[ $EUID -ne 0 ]];
then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Move to Root Folder
cd /root

# Prompt to add new Domain and SSL Cert to Middle Man
STATUS="Prompt - Add new Domain and SSL Cert to Middle Man"
finish="-1"
while [ "$finish" = '-1' ]
do
    finish="1"
    echo
    read -p "Add new SSL domain to The Middle Man [y/n]? " answer

    if [ "$answer" = '' ];
    then
        answer=""
    else
        case $answer in
            y | Y | yes | YES ) answer="y"; adddomain="1";;
            n | N | no | NO ) answer="n"; adddomain="0"; exit 1;;
            *) finish="-1";
                echo -n 'Invalid Response\n';
        esac
    fi
done

# Get SSL Domain Name
finish="-1"
STATUS="Prompt - Enter Domain Name"
while [ "$finish" = '-1' ]
do
    finish="1"
    echo
    read -p "Please enter the domain name to be added to The Middle Man [$defaulthn]: " HOSTNAME
    HOSTNAME=${HOSTNAME:-$defaulthn}
    echo
    $HOSTNAME=$(echo "$HOSTNAME" | awk -F[/:] '{print $4}')
    read -p "New Domain: $HOSTNAME [y/n]? " answer

    if [ "$answer" = '' ];
    then
        answer=""
    else
        case $answer in
            y | Y | yes | YES ) answer="y";;
            n | N | no | NO ) answer="n"; finish="-1"; exit 1;;
            *) finish="-1";
            echo -n 'Invalid Response\n';
        esac
    fi
done

# Get Proxy Site URL
STATUS="Prompt - Destination Domain URL"
finish="-1"
while [ "$finish" = '-1' ]
do
    finish="1"
    echo
    read -p "Enter destination proxy URL for $HOSTNAME SSL domain [$defaultproxy]: " PROXY
    PROXY=${PROXY:-$defaultproxy}
    echo
    
    # extract the protocol
    proto="$(echo $PROXY | grep :// | sed -e's,^\(.*://\).*,\1,g')"
    # set default proto if none exists 
    if [[ -z "$proto" ]]; then
        proto="http://"
    fi
    # remove the protocol
    url="$(echo ${PROXY/$proto/})"
    # extract the user (if any)
    user="$(echo $url | grep @ | cut -d@ -f1)"
    # extract the host and port
    hostport="$(echo ${url/$user@/} | cut -d/ -f1)"
    # by request host without port    
    host="$(echo $hostport | sed -e 's,:.*,,g')"
    # by request - try to extract the port
    port="$(echo $hostport | sed -e 's,^.*:,:,g' -e 's,.*:\([0-9]*\).*,\1,g' -e 's,[^0-9],,g')"
    # extract the path (if any)
    path="$(echo $url | grep / | cut -d/ -f2-)"

    PROXY="${proto}${host}/${path}"
    
    read -p "Proxy URL: $PROXY [y/n]? " answer

    if [ "$answer" = '' ];
    then
        answer=""
    else
        case $answer in
            y | Y | yes | YES ) answer="y";;
            n | N | no | NO ) answer="n"; finish="-1"; exit 1;;
            *) finish="-1";
            echo -n 'Invalid Response\n';
        esac
    fi
done

# Create SSL Domain NGINX Virtual Host
#cp /etc/nginx/conf.d/nginx-confd-default /etc/nginx/conf.d/$HOSTNAME.conf
#sed -i "s/<domain>/$HOSTNAME/g" /etc/nginx/conf.d/$HOSTNAME.conf
#sed -i "s@<proxy>@$PROXY@g" /etc/nginx/conf.d/$HOSTNAME.conf

# Create PageSpeed Cache Dir
#mkdir -p /var/cache/${HOSTNAME}
#chmod 700 /var/cache/${HOSTNAME}
#chown nginx:nginx /var/cache/${HOSTNAME}

# Create Site Root for SSL Domain
#mkdir -p /var/www/${HOSTNAME}/.well-known

# Restart NGINX to enable http for cert generation
#service nginx restart

# Create Initial Lets Encrypt Cert for SSL Domain
#certbot certonly --webroot -w /var/www/$HOSTNAME -d $HOSTNAME -d www.$HOSTNAME

# Create Local Cert
#openssl dhparam -out /etc/letsencrypt/live/$HOSTNAME/dhparams.pem 2048

# Update Selinux and Permissions
#chown -R nginx:nginx /var/www
#semanage fcontext -a -t httpd_sys_content_t /var/www/$HOSTNAME/*
#restorecon -R -v /var/www

# certbot --dry-run renew

# Enable SSL in NGINX Virtual Host File
#sed -i '/^#/ s/^#//' /etc/nginx/conf.d/$HOSTNAME.conf

# Reload NGINX to enable the new domain
#service nginx reload

# Reload Varnish to enable the new domain
#service varnish reload

# Finished
echo
echo "After SSL redirection is enabled and tested, run the command to test SSL certificate renwals: certbot --dry-run renew"

