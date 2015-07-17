#!/bin/bash


DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd );
case "$1" in
"disk")
  dev=$(sudo losetup -f)
  sudo losetup $dev $2
  sudo mkfs.ext4 $dev >/dev/null 2>/dev/null
  sudo losetup -d $dev
  ;;
"compose")
  port=$(($RANDOM + ($RANDOM % 2) * 32768))
  pass=$(pwgen -s -1 16)
  shortname=$(echo ${DIR##*/} | tr -d ".")
  cp $DIR/devconfig.conf $DIR/nginxconfig.conf
  sed -i 's_webportout_'$port'_g' $DIR/docker-compose.yml
  sed -i 's_mysqlrootpass_'$pass'_g' $DIR/docker-compose.yml
  sed -i 's_mysqldbdata_'$2'_g' $DIR/docker-compose.yml
  sed -i 's_upspace_'$DIR/space'_g' $DIR/docker-compose.yml
  sed -i 's_webportout_'$port'_g' $DIR/nginxconfig.conf
  sed -i 's_appservers_'$shortname'_g' $DIR/nginxconfig.conf
  sed -i 's_domain_'${DIR##*/}'_g' $DIR/nginxconfig.conf
  mv $DIR/nginxconfig.conf /etc/nginx/sites-available/${DIR##*/}.conf
  ln -s /etc/nginx/sites-available/${DIR##*/}.conf /etc/nginx/sites-enabled/${DIR##*/}.conf
  service nginx restart
  ;;
"afterdeployhook")
  IFSB=$IFS
  IFS=$'\n'
  for c in `cat docker-compose.yml | shyaml keys`
  do
    cid=$(docker-compose ps -q $c);
    docker exec $cid /afterdeploy.sh
#    docker exec $cid rm /afterdeploy.sh
  done
  IFS=$IFSB;
  ;;
"afterbuildhook")
  . afterbuild.sh
  ;;
*)
  DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd );
  echo $DIR;
  echo ${DIR##*/};
  ;;
esac
