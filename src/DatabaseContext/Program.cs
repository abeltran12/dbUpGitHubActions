using DbUp;

var connectionString =
    args.FirstOrDefault()
    ?? Environment.GetEnvironmentVariable("DB_CONNECTION_STRING")
    ?? "Data Source=localhost,1356;Database=MigratorDb;User Id=sa;Password=TuPassword123!;TrustServerCertificate=true";

Console.WriteLine("Aplicando migraciones...");

EnsureDatabase.For.SqlDatabase(connectionString);

var scriptPath = Path.Combine(AppContext.BaseDirectory, "Scripts");

if (!Directory.Exists(scriptPath))
{
    Console.WriteLine($"❌ No se encontró la carpeta de scripts en: {scriptPath}");
    return -1;
}

var upgrader = DeployChanges.To
    .SqlDatabase(connectionString)
    .WithScriptsFromFileSystem(scriptPath)
    .LogToConsole()
    .Build();

var result = upgrader.PerformUpgrade();

if (!result.Successful)
{
    Console.WriteLine($"Error: {result.Error}");
    return -1;
}

Console.WriteLine("✅ Migraciones aplicadas exitosamente");
return 0;