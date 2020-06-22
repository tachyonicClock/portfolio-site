#!/bin/bash
cd "$(dirname "$0")"

sudo mv /var/www/antonjameslee.com/googlebf36e8a78ba0a7a8.html /tmp
sudo rm /var/www/antonjameslee.com/* -r
sudo mv /tmp/googlebf36e8a78ba0a7a8.html /var/www/antonjameslee.com/
rm public -r
hugo
sudo mv public/* /var/www/antonjameslee.com/.
cd -

