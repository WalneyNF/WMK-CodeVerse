param(
    [string]$WorkDir = "$PWD\wmk-js-build",
    [string]$GodotRef = "4.6.1-stable",
    [string]$ModuleRef = "b1d8b3f4d4688d216657364ddc53db0813444411",
    [int]$Jobs = 2,
    [switch]$SkipDownload
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# The historical WalneyNF/godot master is 4.4-dev. Build against a compatible
# source version in a SEPARATE folder; never rewrite the user's existing fork.
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw "Git nao encontrado no PATH." }
if (-not (Get-Command python -ErrorAction SilentlyContinue)) { throw "Python nao encontrado no PATH." }
if (-not (Get-Command scons -ErrorAction SilentlyContinue)) { throw "SCons nao encontrado. Instale com: py -m pip install scons" }
if (-not (Get-Command node -ErrorAction SilentlyContinue)) { throw "Node.js nao encontrado no PATH." }
if (-not (Get-Command pnpm -ErrorAction SilentlyContinue)) { throw "pnpm nao encontrado. Instale via: npm install -g pnpm@10.11.0" }
New-Item -ItemType Directory -Force -Path $WorkDir | Out-Null
$GodotDir = Join-Path $WorkDir "godot"
if (-not (Test-Path (Join-Path $GodotDir ".git"))) {
    if ($SkipDownload) { throw "Fonte do Godot nao encontrada em $GodotDir." }
    git clone --branch $GodotRef --depth 1 https://github.com/godotengine/godot.git $GodotDir
    if ($LASTEXITCODE -ne 0) { throw "Falha no clone do Godot." }
}
$ModuleDir = Join-Path $GodotDir "modules/GodotJS"
if (-not (Test-Path (Join-Path $ModuleDir ".git"))) {
    if ($SkipDownload) { throw "Modulo GodotJS nao encontrado em $ModuleDir." }
    git clone https://github.com/WalneyNF/GodotJS.git $ModuleDir
    if ($LASTEXITCODE -ne 0) { throw "Falha no clone do GodotJS." }
}
Push-Location $ModuleDir
try {
    git fetch --no-tags origin $ModuleRef
    if ($LASTEXITCODE -ne 0) { throw "Falha ao buscar commit fixado do GodotJS." }
    git checkout --detach $ModuleRef
    if ($LASTEXITCODE -ne 0) { throw "Falha ao selecionar commit do GodotJS." }
    git submodule update --init --recursive
    if ($LASTEXITCODE -ne 0) { throw "Falha ao obter dependencias QuickJS-NG do GodotJS." }
} finally { Pop-Location }
Push-Location $GodotDir
try {
    $version = Get-Content "version.py" -Raw
    if ($version -notmatch 'major\s*=\s*4' -or $version -notmatch 'minor\s*=\s*6') {
        throw "A integracao selecionada exige base Godot 4.6.x. Fonte atual nao compativel."
    }
    Write-Host "Compilando editor Godot com JavaScript e TypeScript (QuickJS)..."
    scons platform=windows target=editor arch=x86_64 use_quickjs_ng=yes use_typescript=yes -j $Jobs
    if ($LASTEXITCODE -ne 0) { throw "SCons falhou. Leia as mensagens de compilacao acima." }
    Write-Host "Executaveis gerados em: $GodotDir/bin"
    Get-ChildItem "bin" -Filter "*.exe" | Select-Object FullName,Length
} finally { Pop-Location }
