#!/bin/bash

set -e

parse_yaml() {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}


usage() { echo "Usage: $0 [-f job yml file] [-i interval for polling job status (default: 30s like 30m 30h )]" 1>&2; exit 1; }

t=1m
while getopts ":f:i:" flag; do
    case "${flag}" in
        f)
            f=${OPTARG}
            ;;
        i)
            t=${OPTARG}
            ;;       
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${f}" ]; then
    usage
fi

eval $(parse_yaml ${f} "config_")

n=$config_metadata_name



echo "f = ${f}"
echo "n = ${n}"
echo "i = ${i}"

kubectl apply -f ${f}

while :; do
  if  kubectl get jobs ${n} -o jsonpath='{.status.conditions[?(@.type=="Complete")].status}' | grep -q 'True'
  then
    echo "the job is done."
    exit 0
  elif kubectl get jobs ${n} -o jsonpath='{.status.conditions[?(@.type=="Failed")].status}'  | grep -q 'True'
  then
    echo "the job failed"
    exit 1
  else 
    sleep ${i}
  fi
done 