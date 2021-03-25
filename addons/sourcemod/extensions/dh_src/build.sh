#!/bin/bash

docker exec -it sourcemod /bin/bash /alliedmodders/sourcemod/extensions/public/addons/sourcemod/extensions/dh_src/build/run.sh

cp -v  ./build/package/addons/sourcemod/extensions/*.so /var/lib/pterodactyl/volumes/3861bb81-ae98-4ad5-be57-47d0503b2373/csgo/addons/sourcemod/extensions/
cp -v  ../../gamedata/*.txt /var/lib/pterodactyl/volumes/3861bb81-ae98-4ad5-be57-47d0503b2373/csgo/addons/sourcemod/gamedata/
touch /var/lib/pterodactyl/volumes/3861bb81-ae98-4ad5-be57-47d0503b2373/csgo/addons/sourcemod/extensions/dh.autoload

wget -O /var/lib/pterodactyl/volumes/3861bb81-ae98-4ad5-be57-47d0503b2373/csgo/addons/sourcemod/gamedata/plugin.turret.txt https://raw.githubusercontent.com/qubka/Zombie-Plague/master/gamedata/plugin.turret.txt
wget -O /var/lib/pterodactyl/volumes/3861bb81-ae98-4ad5-be57-47d0503b2373/csgo/addons/sourcemod/gamedata/plugin.zombieplague.txt https://raw.githubusercontent.com/qubka/Zombie-Plague/master/gamedata/plugin.zombieplague.txt
