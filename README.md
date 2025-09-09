# Ubuntu 开发环境 Docker

这是一个完整的 **Ubuntu 24.04 开发环境 Docker 镜像**，内置 **Docker、Zsh、Oh-My-Zsh、Starship、mise、Homebrew、Vim、Go、Python、Node 及常用开发工具**。

## 功能特点

- 基础镜像：`ubuntu:24.04`，时区为 `Asia/Shanghai`
- 系统工具：`net-tools`、`iproute2`、`curl`、`wget`、`git`、`vim`、`htop` 等
- Docker 已预安装，包括 `docker-ce`、`docker-compose-plugin`、`docker-buildx-plugin`,`containerd`
- Docker 配置文件 `/etc/docker/daemon.json`：

```json
{
    "registry-mirrors": ["https://docker.1ms.run"]
}
```

- Zsh 默认 shell，带 **Oh-My-Zsh** 与插件：`autosuggestions`、`syntax-highlighting`、`completions`
- **Starship 提示符** 已安装
- **mise** 管理开发工具：Go、Python、Node、pipx 包及常用 CLI 工具
- **Homebrew（Linuxbrew）** 已安装并配置 TUNA 镜像
- Vim 已安装 **awesome vimrc**
- 默认用户：`ubuntu`，密码：`1`，无密码 sudo
- WSL2 支持：`systemd=true`

## 使用方法

### 1️⃣ 拉取已有镜像

你可以直接从镜像仓库拉取最新版本，无需本地构建：

```bash
docker pull ghcr.io/bookandmusic/ubuntu-dev:latest
```

### 2️⃣ 运行容器

```bash
docker run -it --rm \
  --name dev-container \
  -v $HOME/projects:/home/ubuntu/projects \
  -v /var/run/docker.sock:/var/run/docker.sock \
  ghcr.io/bookandmusic/ubuntu-dev:latest
```

说明：

- 将本地 `projects` 文件夹挂载到容器 `/home/ubuntu/projects`
- 挂载 Docker socket，可在容器内使用 Docker

## 用户信息

```text
用户名: ubuntu
密码: 1
sudo 免密
```

## 镜像构建建议

- 使用 `--squash` 进一步压缩镜像（Docker 20.10+ 支持）
- 对于大多数用户，直接使用 `docker pull ghcr.io/bookandmusic/ubuntu-dev:latest` 即可，无需自行构建
