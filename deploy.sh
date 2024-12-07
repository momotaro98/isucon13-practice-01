#!/bin/bash

source $HOME/.bashrc

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

echo 'Restarting Go...'
cd $DIR/webapp/go
go build -o isupipe
sudo systemctl stop isupipe-go.service
cd $DIR
sudo systemctl restart isupipe-go.service
echo 'Restarted!'

sudo cp $DIR/systemd/* /etc/systemd/system/
sudo systemctl daemon-reload

echo 'Updating config file...'
sudo cp "$DIR/nginx.conf" /etc/nginx/nginx.conf
sudo cp "$DIR/isupipe.conf" /etc/nginx/sites-enabled/isupipe.conf
# sudo cp "$DIR/redis.conf" /etc/redis/redis.conf
sudo cp "$DIR/mysqld.cnf" /etc/mysql/mysql.conf.d/mysqld.cnf
# sudo cp "$DIR/pdns.conf" /etc/powerdns/pdns.conf
echo 'Updated config file!'

echo 'Restarting services...'
# sudo systemctl restart redis.service
sudo systemctl restart mysql.service
sudo systemctl restart nginx.service
sudo systemctl restart pdns.service
echo 'Restarted!'

echo 'Rotating files'
sudo bash -c 'cp /var/log/nginx/access.log /var/log/nginx/access.log.$(date +%s) && echo > /var/log/nginx/access.log'
sudo bash -c 'cp /var/log/mysql/slow.log /var/log/mysql/slow.log.$(date +%s).$(git rev-parse HEAD) && echo > /var/log/mysql/slow.log'
echo 'Rotated!'

