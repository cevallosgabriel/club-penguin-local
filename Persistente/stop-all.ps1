<#
.SYNOPSIS
    Detiene todos los servicios de Club Penguin Local
#>
param([switch]$IncludeDocker)

Write-Host "Deteniendo Servicios..." -ForegroundColor Red

$pythonProcesses = Get-Process -Name "python", "python3" -ErrorAction SilentlyContinue
if ($pythonProcesses) {
    foreach ($proc in $pythonProcesses) {
        try {
            $cmdLine = (Get-CimInstance Win32_Process -Filter "ProcessId = $($proc.Id)").CommandLine
            if ($cmdLine -match "(houdini|dash|timeline|bootstrap|Timeline)" ) {
                Write-Host "Deteniendo Python PID $($proc.Id)" -ForegroundColor Yellow
                Stop-Process -Id $proc.Id -Force
            }
        } catch {}
    }
}

if ($IncludeDocker) {
    Write-Host "Deteniendo Docker..." -ForegroundColor Yellow
    Push-Location "C:\cpps"
    docker compose down 2>&1
    Pop-Location
}

Write-Host "Servicios detenidos" -ForegroundColor Green
