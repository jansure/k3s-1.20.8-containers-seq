#/bin/sh

set -e

if [ -n ${DEBUG} ]; then
    set -x
fi

if [ -z $1 ]; then
    echo "error: image name required as argument. exiting..."
    exit 1
fi

IMAGE=$1
SEVERITIES="HIGH,CRITICAL"
docker pull --platform linux/amd64 ${IMAGE}
trivy --quiet image --severity ${SEVERITIES}  --no-progress --ignore-unfixed ${IMAGE}
docker pull --platform linux/arm64 ${IMAGE}
trivy --quiet image --severity ${SEVERITIES}  --no-progress --ignore-unfixed ${IMAGE}
exit 0
