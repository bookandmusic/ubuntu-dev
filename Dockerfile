FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
SHELL ["/bin/bash", "-c"]

# ------------------ 系统依赖 + Docker ------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        net-tools iproute2 iputils-ping dnsutils traceroute \
        curl wget sudo git vim unzip tar gnupg lsb-release software-properties-common \
        ca-certificates zsh build-essential procps jq htop gnupg2 lsb-release \
        openssh-client openssh-server && \
    update-alternatives --install /usr/bin/editor editor /usr/bin/vim 100 && \
    update-alternatives --set editor /usr/bin/vim && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && \
    usermod -aG docker ubuntu && \
    mkdir -p /etc/docker && \
    echo -e "{\n    \"registry-mirrors\": [\n        \"https://docker.1ms.run\"\n    ]\n}" > /etc/docker/daemon.json && \
    rm -rf /var/lib/apt/lists/*

# ------------------ 用户配置 + starship ------------------
RUN echo "ubuntu:1" | chpasswd && \
    usermod -aG sudo ubuntu && \
    chsh -s $(which zsh) ubuntu && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu && chmod 440 /etc/sudoers.d/ubuntu && \
    echo -e "[boot]\nsystemd=true\n[user]\ndefault=ubuntu" > /etc/wsl.conf && \
    curl -sS https://starship.rs/install.sh | sh -s -- -y -b /usr/local/bin

USER ubuntu
WORKDIR /home/ubuntu
SHELL ["/bin/zsh", "-lc"]

# ------------------ oh-my-zsh + 插件 ------------------
RUN git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git $HOME/.oh-my-zsh && \
    mkdir -p $HOME/.oh-my-zsh/custom/plugins && \
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && \
    git clone --depth=1 https://github.com/zsh-users/zsh-completions $HOME/.oh-my-zsh/custom/plugins/zsh-completions && \
    cp $HOME/.oh-my-zsh/templates/zshrc.zsh-template $HOME/.zshrc && \
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/g' $HOME/.zshrc && \
    sed -i 's/plugins=(git)/plugins=(git sudo z zsh-autosuggestions zsh-syntax-highlighting zsh-completions python golang starship)/g' $HOME/.zshrc

# ------------------ mise + Homebrew + vimrc + 工具链 ------------------
RUN curl https://mise.run | MISE_INSTALL_PATH=$HOME/.local/bin/mise sh && \
    echo 'eval "$($HOME/.local/bin/mise activate zsh)"' >> $HOME/.zshrc && \
    eval "$($HOME/.local/bin/mise activate zsh)" && \
    mise plugin add python https://github.com/olofvndrhr/asdf-python.git && \
    mise settings experimental=true && \
    mise use -g bat eza ansible uv duf fd fzf gdu lazydocker lazygit ripgrep poetry python@3.13.7 go node pipx btop \
    go:github.com/incu6us/goimports-reviser/v3 \
    go:github.com/a8m/tree/cmd/tree \
    go:mvdan.cc/gofumpt \
    go:github.com/golangci/golangci-lint/cmd/golangci-lint \
    go:github.com/securego/gosec/v2/cmd/gosec \
    go:github.com/fzipp/gocyclo/cmd/gocyclo \
    pipx:glances pipx:httpie pipx:ipython pipx:litecli pipx:mycli pipx:tldr && \
    git clone --depth=1 https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/install.git $HOME/brew-install && \
    /bin/bash $HOME/brew-install/install.sh && rm -rf $HOME/brew-install && \
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> $HOME/.zshrc && \
    echo "export HOMEBREW_PIP_INDEX_URL=\"https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple\"" >> $HOME/.zshrc && \
    echo "export HOMEBREW_BOTTLE_DOMAIN=\"https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles\"" >> $HOME/.zshrc && \
    git clone --depth=1 https://github.com/amix/vimrc.git $HOME/.vim_runtime && \
    sh $HOME/.vim_runtime/install_awesome_vimrc.sh && \
    eval "$($HOME/.local/bin/mise activate zsh)" && \
    sudo rm -rf $HOME/go $HOME/.cache/* && \
    go env -w GOPROXY=https://goproxy.io,direct && \
    npm config set registry https://registry.npmmirror.com/ && \
    pip config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple && \
    mkdir -p $HOME/.config/uv && \
    echo -e "[[index]]\nurl = \"https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple/\"\ndefault = true" > $HOME/.config/uv/uv.toml

CMD ["zsh"]
