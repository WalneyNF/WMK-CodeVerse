param(
    [Parameter(Mandatory=$true)][string]$Distribution,
    [string]$LuaVersion = "0.8.2"
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$api = "https://api.github.com/repos/gilzoide/lua-gdextension/releases/tags/$LuaVersion"
$headers = @{ "User-Agent" = "WMK-Godot-Builder"; "Accept" = "application/vnd.github+json" }
Write-Host "Buscando Lua GDExtension $LuaVersion..."
$release = Invoke-RestMethod -Uri $api -Headers $headers
# Use the stable Lua 5.4 variant, not LuaJIT (LuaJIT is a separate runtime).
$assets = @($release.assets | Where-Object {
    $_.name -match '\.zip$' -and $_.name -notmatch '(?i)luajit|source'
})
if ($assets.Count -ne 1) {
    throw "Esperado um arquivo ZIP Lua 5.4; encontrados: $($assets.name -join ', ')"
}
$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("wmk-lua-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $tmp | Out-Null
try {
    $archive = Join-Path $tmp $assets[0].name
    Invoke-WebRequest -Uri $assets[0].browser_download_url -Headers $headers -OutFile $archive
    $unpack = Join-Path $tmp "unpacked"
    Expand-Archive -Path $archive -DestinationPath $unpack
    $addon = Get-ChildItem $unpack -Recurse -Directory | Where-Object { $_.Name -eq "lua-gdextension" -and (Test-Path (Join-Path $_.FullName "lua.gdextension")) } | Select-Object -First 1
    if (-not $addon) {
        # Inspect all extension filenames rather than trusting asset layout.
        $extensions = @(Get-ChildItem $unpack -Recurse -Filter "*.gdextension")
        if ($extensions.Count -ne 1) { throw "Nao foi possivel identificar a extensao Lua no pacote." }
        $addon = Get-Item $extensions[0].Directory.FullName
    }
    $projectDir = Join-Path $Distribution "WMK-Lua-Demo"
    $dest = Join-Path $projectDir "addons/lua-gdextension"
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    Copy-Item (Join-Path $addon.FullName "*") -Destination $dest -Recurse -Force
    $ext = @(Get-ChildItem $dest -Recurse -Filter "*.gdextension")
    if ($ext.Count -lt 1) { throw "Extensao Lua ausente no projeto final." }
    # Verificar a biblioteca nativa: manifesto sozinho nao registra LuaScript.
    $windowsDlls = @(Get-ChildItem $dest -Recurse -Filter "*.windows.template_debug.x86_64.dll")
    if ($windowsDlls.Count -lt 1) {
        throw "O pacote Lua nao contem DLL Windows x86_64 necessaria."
    }
    Write-Host "Manifesto Lua: $($ext[0].FullName)"
    Write-Host "DLL Lua Windows: $($windowsDlls[0].FullName)"
    @'
config_version=5

[application]
config/name="WMK Godot Lua Demo"
run/main_scene="res://main.tscn"

[editor_plugins]
enabled=PackedStringArray("res://addons/lua-gdextension/plugin.cfg")
'@ | Set-Content (Join-Path $projectDir "project.godot") -Encoding utf8
    @'
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://welcome.lua" id="1"]

[node name="WMK" type="Node"]
script = ExtResource("1")
'@ | Set-Content (Join-Path $projectDir "main.tscn") -Encoding utf8
    @'
local Welcome = GDCLASS()
Welcome.extends = Node
function Welcome:_ready()
    print("WMK_LUA_54_OK")
end
return Welcome
'@ | Set-Content (Join-Path $projectDir "welcome.lua") -Encoding utf8
    Write-Host "Lua instalado no projeto-modelo: $projectDir"
} finally { Remove-Item $tmp -Force -Recurse -ErrorAction SilentlyContinue }
