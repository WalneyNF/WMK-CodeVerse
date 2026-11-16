# WMK Godot com JavaScript e TypeScript

**Projeto:** Walney Moreira Klein — walneyk@hotmail.com.

Esta branch contem a automacao de integracao do GodotJS no Godot. O fork original `WalneyNF/godot` utiliza codigo Godot 4.4 dev, enquanto o modulo GodotJS atual e construido oficialmente sobre Godot 4.6.1. Para evitar alterar a base historica e perder modificacoes, a compilacao usa a fonte oficial Godot **4.6.1-stable** em pasta isolada e incorpora o modulo do fork **WalneyNF/GodotJS**, fixado no commit `b1d8b3f4d4688d216657364ddc53db0813444411`.

## Compilar no Windows
Requisitos: Git, Python 3.11+, SCons e compilador C++ MSVC/Visual Studio com suporte C++ para desktop.

```powershell
py -m pip install scons
powershell -ExecutionPolicy Bypass -File .\wmk-js\build-windows.ps1 -WorkDir D:\Ferramentas\WMK-GodotJS-Build -Jobs 2
```

Ao finalizar, o executavel do editor aparece em `D:\Ferramentas\WMK-GodotJS-Build\godot\bin\`.

## Compilar via GitHub Actions
No repositorio, abra **Actions > WMK Godot JS TS - Windows > Run workflow** na branch `wmk-js-ts-integration`. Se o build passar, baixe o artefato **WMK-Godot-JS-TS-Windows**.

## Como usar JS/TS
O suporte a JS e implementado pelo modulo GodotJS dentro de `modules/GodotJS`. Para TypeScript, configure o preset pelo menu `Project > Tools > GodotJS > Install Preset files` no editor compilado e execute `npm install` seguido de `npx tsc`, conforme versao e exemplo do modulo.

## Status
- [x] Script Windows para integrar modulo e iniciar compilacao
- [x] Workflow para build Windows e publicacao de artefato
- [ ] Compilacao confirmada no GitHub Actions
- [ ] Script JS de teste executado no editor
- [ ] Export Windows validado
- [ ] Retorno das alteracoes para a master, somente apos validacao

**Nao confundir:** adicionar a automacao ao GitHub nao comprova que a compilacao concluiu. O source original 4.4 dev nao foi atualizado: o build produz uma distribuicao baseada em 4.6.1 com o modulo JS/TS.
