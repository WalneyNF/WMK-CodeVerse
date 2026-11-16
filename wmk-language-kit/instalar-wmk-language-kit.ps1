param(
    [Parameter(Mandatory = $true)][string]$Project,
    [switch]$EnablePlugin
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$projectFile = Join-Path $Project 'project.godot'
if (!(Test-Path $projectFile)) { throw "project.godot nao encontrado: $projectFile" }
$root = Split-Path -Parent $PSCommandPath
$addon = Join-Path $Project 'addons/wmk_language_kit'
New-Item -Path $addon -ItemType Directory -Force | Out-Null
Copy-Item (Join-Path $root 'addons/wmk_language_kit/*') -Destination $addon -Force
$toolsDir = Join-Path $Project 'tools'
New-Item -Path $toolsDir -ItemType Directory -Force | Out-Null
Copy-Item (Join-Path $root '../wmk-portugol/compilador.py') (Join-Path $toolsDir 'wmk-portugol.py') -Force
Write-Host "Plugin e compilador copiados para $Project"
if ($EnablePlugin) {
    $conf = Get-Content $projectFile -Raw -Encoding UTF8
    $enabled = 'res://addons/wmk_language_kit/plugin.cfg'
    if ($conf -notmatch '\[editor_plugins\]') {
        Add-Content -Path $projectFile -Value "`r`n[editor_plugins]`r`nenabled=PackedStringArray(`"$enabled`")`r`n" -Encoding UTF8
    } elseif ($conf -notmatch [regex]::Escape($enabled)) {
        Write-Warning 'Ja ha uma secao [editor_plugins]. Habilite WMK Language Kit manualmente no Godot, para preservar os plugins existentes.'
    }
}
Write-Host 'No Godot: Projeto > Configuracoes do Projeto > Plugins > habilitar WMK Language Kit.'
Write-Host 'Depois: Projeto > Ferramentas > WMK - Criar Script JS / Portugol / Lua.'
