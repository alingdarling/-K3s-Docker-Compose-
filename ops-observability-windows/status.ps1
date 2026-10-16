$ErrorActionPreference = 'Stop'
Set-Location (Split-Path -Parent $MyInvocation.MyCommand.Path)
docker compose ps
Write-Host "`n最近日志："
docker compose logs --tail 30
