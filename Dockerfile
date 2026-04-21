FROM --platform=linux/arm64 kalilinux/kali-rolling

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

# pipx: install to a system-wide location so tools are on PATH for all users
ENV PIPX_HOME=/opt/pipx
ENV PIPX_BIN_DIR=/usr/local/bin

# Disable docs, manpages, locales
RUN printf "path-exclude /usr/share/doc/*\n\
path-exclude /usr/share/man/*\n\
path-exclude /usr/share/locale/*\n\
path-include /usr/share/locale/en*\n" \
> /etc/dpkg/dpkg.cfg.d/01_nodoc

# Core + light pentest tools
RUN apt update && \
    apt install -y --no-install-recommends \
    ca-certificates \
    curl \
    jq \
    git \
    nmap \
    ffuf \
    gobuster \
    sqlmap \
    dnsutils \
    netcat-traditional \
    socat \
    tmux \
    vim \
    zsh \
    unzip \
    gnupg \
    lsb-release && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# -------- Extra pentest & Python tooling --------

RUN apt update && \
    apt install -y --no-install-recommends \
    golang \
    pipx \
    iputils-ping \
    proxychains4 \
    php-cli && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    pipx install impacket

# uv (ARM64)
RUN pipx install uv

# Golang config — ENV persists across all subsequent layers, export in RUN does not
ENV GOROOT=/usr/lib/go
ENV GOPATH=/root/go
ENV PATH=$PATH:/root/go/bin:/usr/lib/go/bin:/root/.pdtm/go/bin

# pdtm
RUN go install github.com/projectdiscovery/pdtm/cmd/pdtm@latest

# -------- Cloud & K8s tooling (kept minimal) --------

# AWS CLI v2 (ARM64)
RUN curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o /tmp/awscliv2.zip && \
    unzip /tmp/awscliv2.zip -d /tmp && \
    /tmp/aws/install && \
    rm -rf /tmp/aws* /usr/local/aws-cli/v2/*/dist/aws_completer

# Google Cloud CLI
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] \
https://packages.cloud.google.com/apt cloud-sdk main" \
> /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
    gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && \
    apt update && \
    apt install -y --no-install-recommends google-cloud-cli && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# kubectl (ARM64)
RUN curl -fsSL \
    https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl \
    -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl

# Helm (ARM64)
RUN curl -fsSL https://get.helm.sh/helm-v3.14.4-linux-arm64.tar.gz | \
    tar -xz && \
    mv linux-arm64/helm /usr/local/bin/helm && \
    rm -rf linux-arm64

# Docker CLI (client only)
RUN apt update && \
    apt install -y --no-install-recommends docker.io && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# -------- Shell --------
RUN sh -c 'echo n | ZSH=/etc/zsh/oh-my-zsh sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"' && \
    usermod -s /usr/bin/zsh root && \
    touch /root/.hushlogin

COPY aliases /etc/zsh/aliases
COPY zshrc /etc/zsh/zshrc

WORKDIR /work
CMD ["/usr/bin/zsh"]
