#!/bin/bash

docker exec -it $(docker ps -aqf "name=sourcemod") /bin/bash
