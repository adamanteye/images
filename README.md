# wine-trade

运行 Windows 券商客户端的 Linux/Wine 镜像。基于 Debian 13 的 Wine 10，包含 32 位和 64 位加载器、中文字体、SSH X11 转发及 waypipe。镜像不包含任何券商安装包或账户信息。

与 `arch` 分支一样，`.github/workflows/build.yml` 在分支推送后调用 `adamanteye/actions` 的 Docker 构建工作流；分支名就是镜像名，发布 `ghcr.io/adamanteye/wine-trade:0.1.0`（amd64）。

本地构建：

```sh
podman build --platform linux/amd64 -t localhost/wine-trade:dev .
```

若 Debian 官方镜像下载较慢，可加 `--build-arg APT_MIRROR=http://mirrors.aliyun.com`。apt 仍会验证 Debian 软件包签名。

## 运行约定

- SSH 监听容器端口 `2222`，仅允许 `wine` 用户以公钥登录。镜像不带固定服务器密钥。
- 启动前挂载 SSH 服务器私钥到 `/etc/ssh/ssh_host_ed25519_key`，公钥列表到 `/etc/ssh/authorized_keys/wine`。
- `/data` 应是 UID/GID 1000 可写的持久目录。Wine prefix 位于 `/data/prefix`，安装包可放在 `/data/downloads`。
- `ssh -Y` 可转发 X11；客户端需要 `xauth`，Wayland 桌面还需要 Xwayland。原生 Wayland 可用 `waypipe ssh`，并在远端 `env -u DISPLAY` 让 Wine 选择 Wayland 驱动。

目标程序从[东方财富官方 PC 客户端页面](https://emdesk.eastmoney.com/pc_activity/Pages/VIPTrade/pages/index.html)下载后再安装。
