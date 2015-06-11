#!/bin/bash
f=$1

ports="3100 3130 3131 3132 3133 3134 3135 3136 3137 3138 3139"
for port in $ports; do
    p=$(($port-100))
    address=`./getHost.sh ${fedrahome}/data/${f}Setup/hosts ${p}`
    host=http://$address
    files="${fedrahome}/data/${f}Setup/endpointsDescription ${fedrahome}/data/${f}Setup/federation.ttl ${fedrahome}/data/${f}Setup/dawIndex.ttl ${fedrahome}/data/${f}Setup/fedraFiles/endpoints"
    for file in $files; do
        sed -i "s,HOST:$port,${host}:$port,g" $file
    done
done