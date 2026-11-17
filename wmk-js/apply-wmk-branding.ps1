param([Parameter(Mandatory=$true)][string]$EngineRoot,[Parameter(Mandatory=$true)][string]$BrandLogo)
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
function Replace-Required([string]$file,[string]$old,[string]$new) {
  if (!(Test-Path $file)) { throw "Arquivo ausente: $file" }
  $source=Get-Content $file -Raw -Encoding UTF8
  if (!$source.Contains($old)) { throw "Trecho nao encontrado para patch em $file : $old" }
  $source=$source.Replace($old,$new)
  Set-Content -Path $file -Value $source -Encoding UTF8 -NoNewline
}
$version=Join-Path $EngineRoot 'version.py'
Replace-Required $version 'short_name = "godot"' 'short_name = "wmk_codeverse"'
Replace-Required $version 'name = "Godot Engine"' 'name = "WMK CodeVerse"'
Replace-Required $version 'website = "https://godotengine.org"' 'website = "https://github.com/WalneyNF/WMK-CodeVerse"'
$about=Join-Path $EngineRoot 'editor/gui/editor_about.cpp'
Replace-Required $about 'set_title(TTRC("Thanks from the Godot community!"));' 'set_title("Sobre o WMK CodeVerse");'
$copyrightOld='String(U"© 2014-present ") + TTR("Godot Engine contributors") + ".\n" +'
$copyrightNew='String(U"WMK CodeVerse — Walney Moreira Klein — walneyk@hotmail.com\n\nBaseado na Godot Engine (MIT).\n\n") + String(U"© 2014-present ") + TTR("Godot Engine contributors") + ".\n" +'
Replace-Required $about $copyrightOld $copyrightNew
$godotjs=Join-Path $EngineRoot 'modules/GodotJS'
$header=Join-Path $godotjs 'weaver/jsb_script_language.h'
$headerText=Get-Content $header -Raw -Encoding UTF8
$pattern='(?ms)#if\s+JSB_USE_TYPESCRIPT\s+virtual\s+String\s+get_extension\(\)\s+const\s+override\s*\{\s*return\s+JSB_TYPESCRIPT_EXT;\s*\}\s*#else\s+virtual\s+String\s+get_extension\(\)\s+const\s+override\s*\{\s*return\s+JSB_JAVASCRIPT_EXT;\s*\}\s*#endif'
$matches=[regex]::Matches($headerText,$pattern)
if ($matches.Count -ne 1) { throw "Patch get_extension nao aplicado: esperada 1 ocorrencia; encontradas $($matches.Count)." }
$replacement='virtual String get_extension() const override { return JSB_JAVASCRIPT_EXT; }'
$patched=[regex]::Replace($headerText,$pattern,$replacement)
Set-Content $header -Value $patched -Encoding UTF8 -NoNewline
# Godot 4.7: Script::instance_has() is not virtual anymore.
# O GodotJS mantem sua implementacao interna, mas nao pode sobrescrever a API base.
$scriptHeader = Join-Path $godotjs 'weaver/jsb_script.h'
$scriptHeaderText = Get-Content $scriptHeader -Raw -Encoding UTF8
$instancePattern = 'virtual\s+bool\s+instance_has\s*\(\s*const\s+Object\s*\*\s*p_this\s*\)\s+const\s+override\s*;'
$instanceMatches = [regex]::Matches($scriptHeaderText, $instancePattern)
if ($instanceMatches.Count -ne 1) {
    throw "Patch de compatibilidade Godot 4.7 instance_has: esperada 1 declaracao, encontradas $($instanceMatches.Count)"
}
$scriptHeaderText = [regex]::Replace($scriptHeaderText, $instancePattern, 'bool instance_has(const Object* p_this) const;')
Set-Content -Path $scriptHeader -Value $scriptHeaderText -Encoding UTF8 -NoNewline
Write-Host "Compatibilidade 4.7: instance_has corrigido para API nao virtual."

# Godot 4.7 C++ API adjustments for GodotJS editor integration.
$exportHeader = Join-Path $godotjs 'weaver-editor/jsb_export_plugin.h'
Replace-Required $exportHeader 'static const HashSet<String> get_ignored_paths() { return ignored_paths_; }' 'static const HashSet<String>& get_ignored_paths() { return ignored_paths_; }'

$editorCpp = Join-Path $godotjs 'weaver-editor/jsb_editor_plugin.cpp'
$editorSource = Get-Content $editorCpp -Raw -Encoding UTF8
if (-not $editorSource.Contains('#include "jsb_editor_plugin.h"')) {
    throw "JS editor plugin source header not found."
}
$editorSource = $editorSource.Replace('#include "jsb_editor_plugin.h"', "#include `"jsb_editor_plugin.h`"`n#include `"servers/display_server.h`"`n#include `"scene/main/scene_tree.h`"")
Set-Content -Path $editorCpp -Value $editorSource -Encoding UTF8 -NoNewline
Write-Host 'Godot 4.7 C++ compatibility: HashSet getter and explicit editor headers.'
# ClassDB 4.7 no longer exposes legacy enum/constant/signal fields.
$compatScript = Join-Path $PSScriptRoot 'compat-classdb-4.7.py'
python $compatScript $EngineRoot
if ($LASTEXITCODE -ne 0) { throw 'GodotJS ClassDB 4.7 compatibility patch failed.' }
$scsub=Join-Path $godotjs 'weaver-editor/templates/SCsub'
Replace-Required $scsub 'language = "ts" if env["use_typescript"] else "js"' 'language = "js" # WMK: criar JavaScript nativo por padrao, TS permanece reconhecido'
$movement=Join-Path $godotjs 'weaver-editor/templates/CharacterBody2D/basic_movement.js.cs'
@'
// meta-description: WMK - movimento 2D (JavaScript valido, W A S D via Input Map)
const { _BASE_, Input, Vector2 } = require("godot");
exports.default = class _CLASS_ extends _BASE_ {
    speed = 220;
    _ready() {
        console.log("WMK_JS_OK");
    }
    _physics_process(_delta) {
        const d = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down");
        this.velocity = new Vector2(d.x * this.speed, d.y * this.speed);
        this.move_and_slide();
    }
}
'@ | Set-Content $movement -Encoding UTF8
$langCpp=Join-Path $godotjs 'weaver/jsb_script_language.cpp'
$languageText = Get-Content $langCpp -Raw -Encoding UTF8
$namePattern = '(?ms)String\s+GodotJSScriptLanguage::get_name\(\)\s+const\s*\{\s*return\s+jsb_typename\(GodotJSScript\);\s*\}'
$nameMatches = [regex]::Matches($languageText, $namePattern)
if ($nameMatches.Count -ne 1) {
    throw "JS language identifier patch expected one match; found $($nameMatches.Count)"
}
$nameReplacement = 'String GodotJSScriptLanguage::get_name() const { return "JavaScript (WMK)"; }'
$languageText = [regex]::Replace($languageText, $namePattern, $nameReplacement)
Set-Content -Path $langCpp -Value $languageText -Encoding UTF8 -NoNewline
Copy-Item -LiteralPath $BrandLogo -Destination (Join-Path $EngineRoot 'editor/icons/Logo.svg') -Force
foreach($name in @('icon.svg','icon_outlined.svg','logo.svg','logo_outlined.svg')) {
  Copy-Item -LiteralPath $BrandLogo -Destination (Join-Path $EngineRoot $name) -Force
}
Write-Host "WMK branding aplicado: version.py, About, logos e GodotJS default .js"
