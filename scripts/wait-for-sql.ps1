param (
    [int]$MaxAttempts = 5,
    [int]$DelaySeconds = 30
)

if (-not $env:DB_CONNECTION_STRING) {
    Write-Error "DB_CONNECTION_STRING no está definido"
    exit 1
}

Write-Host "Esperando disponibilidad de Azure SQL..."

for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {

    Write-Host "Intento $attempt de $MaxAttempts"

    try {
        sqlcmd `
            -C `
            -b `
            -Q "SELECT 1" `
            -d "$env:DB_CONNECTION_STRING" `
            > $null 2>&1

        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Base de datos disponible"
            exit 0
        }
    }
    catch {
        # Silencioso
    }

    if ($attempt -lt $MaxAttempts) {
        Write-Host "Esperando $DelaySeconds segundos..."
        Start-Sleep -Seconds $DelaySeconds
    }
}

Write-Error "La base de datos no respondió después de $MaxAttempts intentos"
exit 1
