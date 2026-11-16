param(
    [string]$WorkDir = (Join-Path (Get-Location).Path "wmk-build"),
    [string]$GodotRef = "4.6.1-stable",
    [string]$GodotJSRef = "b1d8b3f4d4688d216657364ddc53db0813444411",
    [int]$Jobs = 2
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Need([string]$cmd) {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) { throw "Comando obrigatorio ausente: $cmd" }
}
function Check([string]$step) {
    if ($LASTEXITCODE -ne 0) { throw "$step falhou (exit $LASTEXITCODE)" }
}
@("git","python","scons","node","pnpm","dotnet") | ForEach-Object { Need $_ }
New-Item -ItemType Directory -Force -Path $WorkDir | Out-Null
$root = Join-Path $WorkDir "godot"
if (-not (Test-Path (Join-Path $root ".git"))) {
    git clone --branch $GodotRef --depth 1 https://github.com/godotengine/godot.git $root
    Check "Clone Godot"
}
Push-Location $root
try {
    $version = Get-Content "version.py" -Raw
    if ($version -notmatch 'major\s*=\s*4' -or $version -notmatch 'minor\s*=\s*6') {
        throw "Base incompatível; exigido Godot 4.6.x"
    }
    $mod = Join-Path $root "modules/GodotJS"
    if (-not (Test-Path (Join-Path $mod ".git"))) {
        git clone https://github.com/WalneyNF/GodotJS.git $mod
        Check "Clone GodotJS"
    }
    Push-Location $mod
    try {
        git fetch --no-tags origin $GodotJSRef
        Check "Fetch GodotJS"
        git checkout --detach $GodotJSRef
        Check "Checkout GodotJS"
        git submodule update --init --recursive
        Check "Dependencias QuickJS-NG"
        if (-not (Test-Path "quickjs-ng/quickjs.c")) { throw "QuickJS-NG incompleto" }
    } finally { Pop-Location }

    # JS/TS: GodotJS; C#: Godot .NET; GDScript: modulo original.
    # QuickJS-NG evita bibliotecas V8 pre-compiladas.
    scons platform=windows target=editor arch=x86_64 module_mono_enabled=yes use_quickjs_ng=yes use_typescript=yes d3d12=no -j $Jobs
    Check "Compilacao do editor"

    $bin = Join-Path $root "bin"
    $editor = Get-ChildItem $bin -Filter "*.exe" | Where-Object {
        $_.Name -match "editor" -and $_.Name -match "mono" -and $_.Name -notmatch "\.console\."
    } | Select-Object -First 1
    if (-not $editor) { throw "Editor .NET nao encontrado no diretorio bin" }
    & $editor.FullName --headless --version
    Check "Teste de inicializacao do editor"

    & $editor.FullName --headless --generate-mono-glue "./modules/mono/glue"
    Check "Geracao de glue .NET"
    python ./modules/mono/build_scripts/build_assemblies.py --godot-output-dir $bin --godot-platform windows
    Check "Assemblies .NET"

    $assemblyDir = Join-Path $bin "GodotSharp"
    if (-not (Test-Path (Join-Path $assemblyDir "Api"))) { throw "GodotSharp/Api ausente" }
    if (-not (Test-Path (Join-Path $assemblyDir "Tools"))) { throw "GodotSharp/Tools ausente" }

    $output = Join-Path $WorkDir "WMK-Godot-Five-Languages"
    New-Item -ItemType Directory -Force -Path $output | Out-Null
    Copy-Item $editor.FullName -Destination $output -Force
    Copy-Item $assemblyDir -Destination (Join-Path $output "GodotSharp") -Force -Recurse
    Set-Content (Join-Path $output "README-WMK.txt") -Encoding utf8 -Value @"
WMK GODOT - CINCO LINGUAGENS (distribuicao de testes)
GDScript: modulo do editor Godot
C#: integrado ao build .NET e distribuido com GodotSharp
JS: modulo GodotJS compilado com QuickJS-NG
TS: ferramenta GodotJS habilitada, requer compilacao TS por projeto
Lua 5.4: extensao GDExtension no projeto-modelo; NAO integrada ao binario.
Autor: Walney Moreira Klein - walneyk@hotmail.com
"@
    Write-Host "Editor pronto em $output"
} finally { Pop-Location }
