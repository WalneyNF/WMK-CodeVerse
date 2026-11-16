param([Parameter(Mandatory=$true)][string]$Distribution)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$editor = Get-ChildItem $Distribution -Filter "*.exe" | Where-Object { $_.Name -match "editor" -and $_.Name -notmatch "console" } | Select-Object -First 1
if (-not $editor) { throw "Editor WMK nao encontrado: $Distribution" }
$base = Join-Path $PSScriptRoot "playground"
foreach ($demo in @(@{name="2d"; marker="WMK_PLAYGROUND_2D_OK"}, @{name="3d"; marker="WMK_PLAYGROUND_3D_OK"})) {
    $project = Join-Path $base $demo.name
    if (-not (Test-Path (Join-Path $project "project.godot"))) { throw "Projeto ausente: $project" }
    Write-Host "WMK PLAYGROUND: importando $($demo.name)"
    $importLog = & $editor.FullName --headless --editor --path $project --import 2>&1 | Out-String
    $importCode = $LASTEXITCODE
    Write-Host $importLog
    if ($importCode -ne 0 -or $importLog -match '(?m)^\s*(?:ERROR:|FATAL:)') { throw "Importacao falhou: $($demo.name) (exit=$importCode)" }
    Write-Host "WMK PLAYGROUND: executando $($demo.name)"
    $runLog = & $editor.FullName --headless --path $project --quit-after 12 2>&1 | Out-String
    $runCode = $LASTEXITCODE
    Write-Host $runLog
    if ($runCode -ne 0 -or $runLog -notmatch $demo.marker -or $runLog -match '(?m)^\s*(?:ERROR:|FATAL:)') {
        throw "Execucao falhou: $($demo.name) exit=$runCode marcador=$($demo.marker)"
    }
    Write-Host "$($demo.name): smoke test OK"
}
Write-Host "WMK PLAYGROUND: os dois testes passaram."
