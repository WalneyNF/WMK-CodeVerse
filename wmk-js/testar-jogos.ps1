param([Parameter(Mandatory=$true)][string]$Distribution)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$editor = Get-ChildItem $Distribution -Filter "*.exe" | Where-Object { $_.Name -match "editor" -and $_.Name -notmatch "console" } | Select-Object -First 1
if (!$editor) { throw "Editor nao encontrado: $Distribution" }
foreach ($config in @(
    @{ Name='WMK-Jogo-JavaScript'; Marker='WMK_JOGO_JS_OK' },
    @{ Name='WMK-Jogo-Portugol'; Marker='WMK_JOGO_PORTUGOL_OK' }
)) {
    $project = Join-Path $Distribution $config.Name
    if (!(Test-Path (Join-Path $project "project.godot"))) { throw "Projeto nao encontrado: $project" }
    $output = & $editor.FullName --headless --editor --path $project --import 2>&1 | Out-String
    $importExit = $LASTEXITCODE
    Write-Host $output
    if ($importExit -ne 0 -or $output -match '(?m)^\s*(ERROR:|FATAL:|SCRIPT ERROR:)') {
        throw "Importacao falhou para $($config.Name): exit $importExit"
    }
    $output = & $editor.FullName --headless --path $project --quit-after 15 2>&1 | Out-String
    $runExit = $LASTEXITCODE
    Write-Host $output
    if ($runExit -ne 0 -or $output -notmatch $config.Marker -or $output -match '(?m)^\s*(ERROR:|FATAL:|SCRIPT ERROR:)') {
        throw "Jogo $($config.Name) falhou: exit $runExit ou marcador ausente"
    }
    Write-Host "Jogo $($config.Name): APROVADO"
}
