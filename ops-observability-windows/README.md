# Windows 可运行版：Docker Desktop + Docker Compose

此版本让 Windows 用户直接在本机启动 Nginx、Prometheus、Grafana 和 Alertmanager，不需要进入 Red Hat 虚拟机或使用 Kubernetes。容器由 Docker Desktop 的 Linux 容器引擎运行，浏览器入口只绑定本机 `localhost`。

## 准备

- Windows 10/11 x64，已安装 Docker Desktop，并启用 WSL 2 后端及 Linux containers。
- Docker Desktop 已启动；建议为 Docker Desktop 分配至少 2 GiB 内存。
- 首次启动需要联网拉取容器镜像。

## 启动

解压整个 `windows` 文件夹，在该文件夹空白处打开 PowerShell：

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\start.ps1
```

第一次启动会创建 `.env` 并下载镜像。可编辑 `.env` 修改 Grafana 密码，然后再次运行 `.\start.ps1`。

访问地址：

- Nginx：<http://localhost:18080>
- Prometheus targets：<http://localhost:9090/targets>
- Grafana：<http://localhost:3000>，用户名 `admin`，密码为 `.env` 中的值
- Alertmanager：<http://localhost:9093>

Grafana 会自动配置 Prometheus 数据源和“Windows 运维实战总览”仪表盘。它展示 Nginx 请求与连接指标，以及 Prometheus 自身资源指标。此 Compose 版不包含 Kubernetes，也不采集 Windows 主机 CPU/内存；Windows 主机指标需要额外安装 Windows Exporter 并配置 Prometheus。

## 检查与停止

```powershell
.\test.ps1
.\status.ps1
.\stop.ps1
```

`stop.ps1` 会停止并移除容器，但保留 Prometheus 和 Grafana 数据卷。需要彻底清除历史数据时，可手动运行 `docker compose down -v`。

## 常见问题

- `docker` 找不到：先安装 Docker Desktop，再重新打开 PowerShell。
- Docker Engine 未运行：打开 Docker Desktop，等状态显示 Engine running。
- 端口被占用：关闭占用 `18080`、`9090`、`9093` 或 `3000` 的程序，或修改 `docker-compose.yml` 左侧端口。
- 镜像下载失败：确认网络可访问镜像仓库，然后运行 `docker compose pull` 和 `.\start.ps1`。
