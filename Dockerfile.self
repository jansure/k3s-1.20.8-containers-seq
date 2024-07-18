FROM harbor.xxx.com/base/k3s-dapper-jf:latest AS builder

RUN ls -lrt /root/.ssh/
#RUN ping igitlab.xxx.com  -c 5
ARG DOCKER_HOST=tcp://10.121.16.40:2375
ARG artifactVersion
ARG artifactType
ARG artifactDateTime=20221017203118
ARG artifactRef=master

USER root
#RUN apk add ip6tables
#ADD config.toml /etc/containerd/config.toml
COPY . .
ENV GOPROXY=https://goproxy.cn,direct
#ADD config.toml /etc/containerd/config.toml
#RUN nohup containerd & >> nohup  && nohup dockerd & >> nohup
#RUN more nohup
RUN set -x && ps -ef
ENV DOCKER_BUILDKIT=1
ENV DOCKER_HOST=$DOCKER_HOST
ENV artifactVersion=$artifactVersion
ENV artifactType=$artifactType
ENV artifactDateTime=20221017203118
ENV artifactRef=$artifactRef
RUN if [ "`arch`" = "aarch64" ]; then \
    mkdir -p ~/.docker/cli-plugins; \
    curl -o docker-buildx http://jfrog.xxx.com/artifactory/lecp-docker-buildx/aarch64/docker-buildx; \
    chmod +x docker-buildx && cp docker-buildx ~/.docker/cli-plugins/; \
else \
    mkdir -p ~/.docker/cli-plugins; \
    curl -o docker-buildx http://jfrog.xxx.com/artifactory/lecp-docker-buildx/x86_64/docker-buildx; \
    chmod +x docker-buildx && cp docker-buildx ~/.docker/cli-plugins/; \
fi
RUN make generate
RUN scripts/entry.sh ci

FROM harbor.xxx.com/base/jfrog-client:latest
ARG artifactProjectName=lecp-mec-k3s
ARG artifactVersion
ARG artifactType
ARG artifactDateTime=20221017203118
ARG artifactRef=master
WORKDIR /
COPY --from=builder /k3s /
COPY --from=builder /k3s-airgap-images.tar /
RUN jf rt u --server-id=${artifactType} k3s ${artifactProjectName}/${artifactType}/${artifactVersion}/`arch`/k3s
RUN jf rt u --server-id=${artifactType} k3s-airgap-images.tar ${artifactProjectName}/${artifactType}/${artifactVersion}/`arch`/k3s-airgap-images.tar
