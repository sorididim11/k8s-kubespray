#!/bin/bash

set -e



usage() { echo "Usage: $0 [-v image version] [-t <cpu/gpu/all> (default: all)]" 1>&2; exit 1; }

TYPE="all"
while getopts ":v:t:" flag; do
    case "${flag}" in
        v)
            VERSION=${OPTARG}
            ;;            
        t)
            TYPE=${OPTARG}
            ;;      
        *)
            echo "invalid args..."
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${VERSION}" ]; then
    usage
fi

echo "VERSION = ${VERSION}"
echo "TYPE = ${TYPE}"

if [ "${TYPE}" == "cpu" -o "${TYPE}" == "all" ]; then
sudo docker build -t sorididim11/dl-base-cpu:${VERSION} -f Dockerfile.dl-base --build-arg DEVICE_TYPE=cpu --build-arg VERSION=${VERSION} .  && \
sudo docker build -t sorididim11/mlbasic-lab-cpu:${VERSION} -f Dockerfile.mlbasic-lab --build-arg DEVICE_TYPE=cpu --build-arg VERSION=${VERSION} . && \
sudo docker build -t sorididim11/bdtf-lab-cpu:${VERSION} -f Dockerfile.bdtf-lab --build-arg DEVICE_TYPE=cpu --build-arg VERSION=${VERSION} . && \
sudo docker build -t sorididim11/dl-lab-cpu:${VERSION} -f Dockerfile.dl-lab --build-arg ROOT_IMAGE=ufoym/deepo:all-py36-jupyter-cpu --build-arg VERSION=${VERSION} . && \
sudo docker build -t sorididim11/spark-lab-cpu:${VERSION} -f Dockerfile.spark-lab --build-arg VERSION=${VERSION} . && \
sudo docker build -t sorididim11/r-lab-cpu:${VERSION} -f Dockerfile.r-lab  --build-arg VERSION=${VERSION} . && \
sudo docker build -t sorididim11/mllight-lab-cpu:${VERSION} -f Dockerfile.mllight-lab --build-arg DEVICE_TYPE=cpu --build-arg VERSION=${VERSION} .
fi



if [ "${TYPE}" == "gpu" -o "${TYPE}" == "all" ]; then
sudo docker build -t sorididim11/dl-base-gpu:${VERSION} -f Dockerfile.dl-base --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${VERSION} . && \
sudo docker build -t sorididim11/mlbasic-lab-gpu:${VERSION} -f Dockerfile.mlbasic-lab --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${VERSION} .  && \
sudo docker build -t sorididim11/bdtf-lab-gpu:${VERSION} -f Dockerfile.bdtf-lab --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${VERSION} .  && \
sudo docker build -t sorididim11/dl-lab-gpu:${VERSION} -f Dockerfile.dl-lab --build-arg VERSION=${VERSION} . && \
sudo docker build -t sorididim11/mllight-lab-gpu:${VERSION} -f Dockerfile.mllight-lab --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${VERSION} .
fi