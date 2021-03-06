#!/bin/bash
strategy=$1
queriesFile=$2
l="$3"
localPort=$4
ldfServer=$5
federationFile=$6
availability=$7
answersFolder=$8
publicEndpoint=${9}
engine=${10}
configFile=${11}
hdtFile=${12}
anapsidFederationFile=${13}
updatesFile=${14}
localProxyPort=${15}
action=${16}
n=0
queryFile=`mktemp`
tmpFileNR=`mktemp`

if [ "$strategy" = "FEDERATION" ]; then
  if [ "$action" != "justExecute" ]; then
     cd $fusekiPath
     fuseki-server --port=${localPort} --update --mem /ds > outputFederationEndpoint${localPort} &
     pidFE=$!
     sleep 10
  fi
  if [ "$action" != "justReplicate" ]; then
     cd $fedrahome/proxy
     address=${host#http://}
     java -cp .:$httpcomponentsClientPath/lib/* SingleEndpointProxy2 $address ${localPort} ${localProxyPort} > $tmpFileNR &
     pidProxy=$!
  fi
fi
if [ "$strategy" = "LOCAL" ]; then
  cd $fusekiHDTPath
  bin/hdtEndpoint.sh --localhost --port=${localPort} --hdt=$hdtFile /ds > outputLocalEndpoint${localPort} &
fi

for qn in $l; do
  head -n $qn $queriesFile | tail -n 1 > $queryFile
  cd $fedrahome/scripts
  (
  flock -e 200
  ./runOneQuery.sh $strategy $queryFile $localPort $ldfServer $federationFile $availability $answersFolder/query${qn} $publicEndpoint $engine $configFile $anapsidFederationFile $updatesFile ${localProxyPort} $action
  ) 200>>${federationFile}
done

if [ "$strategy" = "FEDERATION" ] ; then
  echo "Federation member ${localPort} ended"
  echo "$tmpFileNR"
  echo "$pidFE"
  echo "$pidProxy"
fi

rm $queryFile
