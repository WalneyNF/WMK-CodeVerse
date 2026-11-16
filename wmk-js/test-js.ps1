param(
    [Parameter(Mandatory=$true)][string]$Distribution
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$editor = Get-ChildItem $Distribution -Filter "*.exe" | Where-Object { $_.Name -match "editor" -and $_.Name -notmatch "console" } | Select-Object -First 1
if (-not $editor) { throw "Editor WMK nao encontrado: $Distribution" }
$project = Join-Path $Distribution "WMK-JS-Demo"
New-Item -ItemType Directory -Force -Path $project | Out-Null
@'
config_version=5

[application]
config/name="WMK CodeVerse JavaScript Demo"
run/main_scene="res://main.tscn"
'@ | Set-Content (Join-Path $project "project.godot") -Encoding utf8
@'
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://welcome.js" id="1"]

[node name="WMK" type="Node"]
script = ExtResource("1")
'@ | Set-Content (Join-Path $project "main.tscn") -Encoding utf8
@'
"use strict";
const { Node } = require("godot");
exports.default = class WMKJavaScriptDemo extends Node {
    _ready() {
        console.log("WMK_JS_OK");
    }
};
'@ | Set-Content (Join-Path $project "welcome.js") -Encoding utf8

Write-Host "Importando projeto e registrando scripts JavaScript..."
$importLog = & $editor.FullName --headless --editor --path $project --import 2>&1 | Out-String
Write-Host $importLog
if ($LASTEXITCODE -ne 0 -or $importLog -match 'ERROR:|FATAL:') { throw "Falha durante importacao JavaScript." }
Write-Host "Executando cena JavaScript..."
$log = & $editor.FullName --headless --path $project --quit-after 15 2>&1 | Out-String
Write-Host $log
if ($LASTEXITCODE -ne 0 -or $log -notmatch 'WMK_JS_OK' -or $log -match 'ERROR:|FATAL:') {
    throw "JavaScript nao executou o script de teste com sucesso."
}
Write-Host "WMK JavaScript: cena executada."
