$ErrorActionPreference = 'Stop'
$Base = 'http://localhost'
$Checks = @(
    @{ Name = 'Nginx'; Url = "$Base`:18080/" },
    @{ Name = 'Prometheus targets'; Url = "$Base`:9090/api/v1/targets" },
    @{ Name = 'Grafana health'; Url = "$Base`:3000/api/health" },
    @{ Name = 'Alertmanager'; Url = "$Base`:9093/-/healthy" }
)
foreach ($Check in $Checks) {
    try {
        $Response = Invoke-WebRequest -Uri $Check.Url -TimeoutSec 5 -UseBasicParsing
        if ($Check.Name -eq 'Prometheus targets') {
            $Targets = ($Response.Content | ConvertFrom-Json).data.activeTargets
            $Down = @($Targets | Where-Object { $_.health -ne 'up' })
            if ($Targets.Count -eq 0 -or $Down.Count -gt 0) {
                throw "Prometheus 有 $($Down.Count) 个异常采集目标。请打开 http://localhost:9090/targets 查看。"
            }
            Write-Host ("{0}: HTTP {1}, {2} 个目标全部 UP" -f $Check.Name, [int]$Response.StatusCode, $Targets.Count)
        } else {
            Write-Host ("{0}: HTTP {1}" -f $Check.Name, [int]$Response.StatusCode)
        }
    } catch {
        throw ("{0} 检查失败：{1}" -f $Check.Name, $_.Exception.Message)
    }
}
