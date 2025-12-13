param (
    [int]$MaxAttempts = 5,
    [int]$DelaySeconds = 30
)

if (-not $env:DB_CONNECTION_STRING) {
    Write-Error "DB_CONNECTION_STRING no está definido"
    exit 1
}

# Parsear connection string
$builder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder
$builder.set_ConnectionString = $env:DB_CONNECTION_STRING

$server   = $builder.DataSource
$database = $builder.InitialCatalog
$user     = $builder.UserID
$password = $builder.Password

Write-Host "Esperando disponibilidad de Azure SQL..."

for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {

    Write-Host "Intento $attempt de $MaxAttempts"

    sqlcmd `
        -S "$server" `
        -d "$database" `
        -U "$user" `
        -P "$password" `
        -C `
        -b `
        -Q "SELECT 1" `
        > $null 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Base de datos disponible"
        exit 0
    }

    if ($attempt -lt $MaxAttempts) {
        Write-Host "Esperando $DelaySeconds segundos..."
        Start-Sleep -Seconds $DelaySeconds
    }
}

Write-Error "La base de datos no respondió después de $MaxAttempts intentos"
exit 1
