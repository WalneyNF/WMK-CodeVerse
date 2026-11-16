param(
    [Parameter(Mandatory=$true)][string]$Distribution
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$editor = Get-ChildItem $Distribution -Filter "*.exe" |
    Where-Object { $_.Name -match "editor" -and $_.Name -notmatch "console" } |
    Select-Object -First 1
if (-not $editor) { throw "Editor WMK nao encontrado: $Distribution" }
$project = Join-Path $Distribution "WMK-Lua-Demo"
if (-not (Test-Path (Join-Path $project "project.godot"))) {
    throw "Projeto Lua nao existe: $project"
}
$manifest = @(Get-ChildItem (Join-Path $project "addons") -Recurse -Filter "*.gdextension")
if ($manifest.Count -lt 1) { throw "Lua GDExtension sem manifesto" }

Write-Host "WMK LUA: verificando instalacao, manifestos e bibliotecas..."
$manifest | ForEach-Object { Write-Host "Manifesto: $($_.FullName)" }
$pluginCfg = Join-Path $project "addons/lua-gdextension/plugin.cfg"
Write-Host "plugin.cfg encontrado: $(Test-Path $pluginCfg)"
Write-Host "Editor: $($editor.FullName)"
Write-Host "Projeto: $project"

Write-Host "WMK LUA: inicializando editor para importar projeto..."
$importOutput = & $editor.FullName --headless --editor --path $project --import 2>&1 | Out-String
$importExit = $LASTEXITCODE
Write-Host $importOutput
Write-Host "WMK LUA IMPORT_EXIT=$importExit"
$importHasError = [bool]($importOutput -match '(?m)^\s*(?:ERROR:|FATAL:)')
$importCompleted = [bool]($importOutput -match '\[\s*DONE\s*\].*first_scan_filesystem')
Write-Host "WMK LUA IMPORT_DONE=$importCompleted IMPORT_ERRORS=$importHasError"

# Uma importacao que terminou o escaneamento pode retornar nao-zero sem mensagem
# diagnostica. Nessa situacao, o teste real de execucao define se Lua funciona.
# Nao suprimir erros explicitamente reportados nem falhas da execucao.
if ($importHasError) {
    throw "Importacao Lua reportou ERROR/FATAL. Consulte o log acima."
}
if ($importExit -ne 0 -and -not $importCompleted) {
    throw "Importacao Lua nao concluiu (exit=$importExit). Consulte o log acima."
}
if ($importExit -ne 0) {
    Write-Warning "Importacao retornou $importExit apesar de DONE; validando o script Lua real antes de aprovar."
}

Write-Host "WMK LUA: executando cena de teste..."
$output = & $editor.FullName --headless --path $project --quit-after 20 2>&1 | Out-String
$runtimeExit = $LASTEXITCODE
Write-Host $output
Write-Host "WMK LUA RUNTIME_EXIT=$runtimeExit"
$hasMarker = [bool]($output -match 'WMK_LUA_54_OK')
$runtimeHasError = [bool]($output -match '(?m)^\s*(?:ERROR:|FATAL:)')
Write-Host "WMK LUA RUNTIME_MARKER=$hasMarker RUNTIME_ERRORS=$runtimeHasError"
if ($runtimeExit -ne 0 -or -not $hasMarker -or $runtimeHasError) {
    throw "Lua nao executou a cena: exit=$runtimeExit marcador=$hasMarker erros=$runtimeHasError"
}
Write-Host "WMK LUA 5.4: execucao de cena comprovada."
