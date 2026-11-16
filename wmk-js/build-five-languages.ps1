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

    # WMK: identidade visual, nome do editor, Sobre e criacao de .js
    $branding = Join-Path $PSScriptRoot "apply-wmk-branding.ps1"
    $logo = (Resolve-Path (Join-Path $PSScriptRoot "../branding/wmk-codeverse-icon.svg")).Path
    & $branding -EngineRoot $root -BrandLogo $logo

    # PNG e ICO gerados a partir da logo oficial com sharp (Node.js).
    $brandDeps = Join-Path $WorkDir "brand-tools"
    New-Item -ItemType Directory -Force -Path $brandDeps | Out-Null
    npm install --prefix $brandDeps --no-save --no-package-lock sharp@0.34.5
    Check "Instalar conversor de SVG"
    $env:NODE_PATH = Join-Path $brandDeps "node_modules"
    node (Join-Path $PSScriptRoot "brand-assets.cjs") $root $logo
    Check "Gerar icones WMK, splash e recursos Windows"

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
    Copy-Item $editor.FullName -Destination (Join-Path $output "WMK-CodeVerse-editor.exe") -Force
    Copy-Item $assemblyDir -Destination (Join-Path $output "GodotSharp") -Force -Recurse
    Copy-Item (Join-Path $root "LICENSE.txt") -Destination (Join-Path $output "LICENSE-Godot.txt") -Force
    Copy-Item (Join-Path $root "AUTHORS.md") -Destination (Join-Path $output "AUTHORS-Godot.md") -Force
    Copy-Item $logo -Destination (Join-Path $output "WMK-CodeVerse-Logo.svg") -Force
    Set-Content (Join-Path $output "README-WMK.txt") -Encoding utf8 -Value @"
WMK CODEVERSE - PREVIEW WINDOWS (distribuicao experimental)
GDScript: modulo do editor Godot
C#: integrado ao build .NET e distribuido com GodotSharp
JS: modulo GodotJS compilado com QuickJS-NG
TS: reconhecido pelo GodotJS, requer compilacao TS com tsc por projeto
JS: extensao .js prioritaria no assistente nativo apos o patch WMK
Branding: logo, splash, About e exe WMK-CodeVerse-editor.exe
Licencas: original Godot MIT em LICENSE-Godot.txt, autores em AUTHORS-Godot.md
Lua 5.4: extensao GDExtension no projeto-modelo; NAO integrada ao binario.
Autor: Walney Moreira Klein - walneyk@hotmail.com
"@
    Write-Host "Editor pronto em $output"
} finally { Pop-Location }
