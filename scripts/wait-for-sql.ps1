param (
    [int]$MaxAttempts = 5,
    [int]$DelaySeconds = 30
)

if (-not $env:DB_CONNECTION_STRING) {
    Write-Error "DB_CONNECTION_STRING no está definido"
    exit 1
}

Write-Host "Esperando disponibilidad de Azure SQL..."
Write-Host "Connection String: $($env:DB_CONNECTION_STRING.Substring(0, 50))..."

for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {
    Write-Host "Intento $attempt de $MaxAttempts"

    try {
        # Crear conexión directamente con el connection string
        $connection = New-Object System.Data.SqlClient.SqlConnection($env:DB_CONNECTION_STRING)
        $connection.Open()
        
        # Ejecutar query simple para verificar conectividad
        $command = $connection.CreateCommand()
        $command.CommandText = "SELECT 1"
        $result = $command.ExecuteScalar()
        
        $connection.Close()
        
        Write-Host "✓ Base de datos disponible (resultado: $result)"
        exit 0
    }
    catch {
        Write-Host "✗ Error: $($_.Exception.Message)"
        
        if ($attempt -lt $MaxAttempts) {
            Write-Host "Esperando $DelaySeconds segundos antes del siguiente intento..."
            Start-Sleep -Seconds $DelaySeconds
        }
    }
    finally {
        if ($null -ne $connection -and $connection.State -eq 'Open') {
            $connection.Close()
            $connection.Dispose()
        }
    }
}

Write-Error "❌ La base de datos no respondió después de $MaxAttempts intentos"
exit 1
