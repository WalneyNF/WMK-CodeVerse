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
$old=@'
#if JSB_USE_TYPESCRIPT
    virtual String get_extension() const override { return JSB_TYPESCRIPT_EXT; }
#else
    virtual String get_extension() const override { return JSB_JAVASCRIPT_EXT; }
#endif
'@
$new=@'
    // WMK: arquivos .js podem ser criados diretamente pelo assistente do editor.
    // .ts continua reconhecido, mas requer transpilar usando tsc.
    virtual String get_extension() const override { return JSB_JAVASCRIPT_EXT; }
'@
Replace-Required $header $old.TrimEnd() $new.TrimEnd()
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
$oldName=@'
String GodotJSScriptLanguage::get_name() const
{
    return jsb_typename(GodotJSScript);
}
'@
$newName=@'
String GodotJSScriptLanguage::get_name() const
{
    return "JavaScript (WMK)";
}
'@
Replace-Required $langCpp $oldName.TrimEnd() $newName.TrimEnd()
Copy-Item -LiteralPath $BrandLogo -Destination (Join-Path $EngineRoot 'editor/icons/Logo.svg') -Force
foreach($name in @('icon.svg','icon_outlined.svg','logo.svg','logo_outlined.svg')) {
  Copy-Item -LiteralPath $BrandLogo -Destination (Join-Path $EngineRoot $name) -Force
}
Write-Host "WMK branding aplicado: version.py, About, logos e GodotJS default .js"
