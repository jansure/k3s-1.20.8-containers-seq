#!/bin/bash

DIR=$(dirname $0)
pushd $DIR
#git clone git@igitlab.xxx.com:binary/lecp-mec-k3s.git downloads/lecp-mec-k3s
git clone https://igitlab.xxx.com/binary/lecp-mec-k3s.git downloads/lecp-mec-k3s
host_dir=$(docker inspect --format "{{ range .Mounts }}{{ if eq .Destination \"/builds\" }}{{ .Source }}{{ end }}{{ end }}" `head -1 /proc/self/cgroup|cut -d/ -f3 | awk -F '-' '{print $NF}' | awk -F '.' '{print $1}'`)
docker run --rm -v ${host_dir}$(pwd|sed 's#builds/##g'):/go/src/github.com/rancher/k3s/ \
	-e GOPROXY=http://pip.xxx.com/repository/go-group/ \
	harbor.xxx.com/cicd/k3s-build:1.20.8 lecp_ci
popd
