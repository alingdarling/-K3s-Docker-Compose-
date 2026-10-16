$ErrorActionPreference = 'Stop'
$ProjectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ProjectDir

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw '找不到 docker。请先安装并启动 Docker Desktop（使用 Linux containers / WSL2）。'
}
docker info *> $null
if ($LASTEXITCODE -ne 0) {
    throw 'Docker Engine 未运行。请打开 Docker Desktop，等待左下角显示 Engine running 后重试。'
}
docker compose version *> $null
if ($LASTEXITCODE -ne 0) {
    throw '需要 Docker Compose v2。请更新 Docker Desktop 后重试。'
}

if (-not (Test-Path '.env')) {
    Copy-Item '.env.example' '.env'
    Write-Host '已创建 .env。首次使用建议编辑其中的 Grafana 密码。' -ForegroundColor Yellow
}

docker compose config -q
if ($LASTEXITCODE -ne 0) { throw 'Compose 配置校验失败。' }
docker compose up -d --pull missing
if ($LASTEXITCODE -ne 0) { throw '容器启动失败；请运行 .\status.ps1 查看日志。' }

Write-Host ''
Write-Host '项目已启动：'
Write-Host '  Nginx:       http://localhost:18080'
Write-Host '  Prometheus:  http://localhost:9090/targets'
Write-Host '  Grafana:     http://localhost:3000  (admin / .env 中的密码)'
Write-Host '  Alertmanager:http://localhost:9093'
