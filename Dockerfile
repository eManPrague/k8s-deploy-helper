FROM docker:20.10.17-dind

ENV HELM_VERSION="2.16.7" \
  KUBECTL_VERSION="1.24.3" \
  YQ_VERSION="4.26.1" \
  KUBEVAL_VERSION="0.16.1" \
  GLIBC_VERSION="2.35-r0" \
  PATH=/opt/kubernetes-deploy:$PATH

# Install pre-req
RUN apk add -U openssl curl tar gzip bash ca-certificates git wget jq libintl coreutils \
  && apk add --virtual build_deps gettext \
  && mv /usr/bin/envsubst /usr/local/bin/envsubst \
  && apk del build_deps

# Install deploy scripts
COPY / /opt/kubernetes-deploy/

# Install glibc for Alpine
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \ 
  && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION/glibc-$GLIBC_VERSION.apk \ 
  && apk add glibc-$GLIBC_VERSION.apk \ 
  && rm glibc-$GLIBC_VERSION.apk

# Install yq
RUN wget -q -O /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v$YQ_VERSION/yq_linux_amd64 && chmod +x /usr/local/bin/yq

# Install kubeval
RUN wget https://github.com/garethr/kubeval/releases/download/v$KUBEVAL_VERSION/kubeval-linux-amd64.tar.gz \
  && tar xvfzmp kubeval-linux-amd64.tar.gz \
  && mv kubeval /usr/local/bin \
  && chmod +x /usr/local/bin/kubeval

# Install kubectl
RUN curl -L -o /usr/bin/kubectl https://dl.k8s.io/release/v$KUBECTL_VERSION/bin/linux/amd64/kubectl \
  && chmod +x /usr/bin/kubectl \
  && kubectl version --client

# Install Helm
RUN set -x \
  && curl -fSL https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz -o helm.tar.gz \
  && tar -xzvf helm.tar.gz \
  && mv linux-amd64/helm /usr/local/bin/ \
  && rm -rf linux-amd64 \
  && rm helm.tar.gz \
  && helm help



