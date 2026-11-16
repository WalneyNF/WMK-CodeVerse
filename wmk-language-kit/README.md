# WMK Language Kit — Assistente de scripts por projeto (experimental)

**Walney Moreira Klein — walneyk@hotmail.com**

## Objetivo

Corrigir o fluxo inicial de criação de arquivos JS sem depender do diálogo nativo que na compilação GodotJS/TypeScript aceita apenas `.ts`.

**Não é uma integração nativa de linguagens.** O plugin adiciona um comando em Projeto > Ferramentas que cria o arquivo apropriado e tenta anexá-lo ao nó selecionado. Não remove o editor original nem altera o código C++.

## Instalação no Windows

Baixe ou clone o repositório e abra PowerShell na raiz:

```powershell
.\wmk-language-kit\instalar-wmk-language-kit.ps1 -Project "D:\MeusJogos\TesteJS001" -EnablePlugin
```

Feche o projeto no Godot durante a cópia. Reabra e verifique **Projeto → Configurações do Projeto → Plugins → WMK Language Kit → Habilitar**.

Selecione um nó e vá a **Projeto → Ferramentas → WMK - Criar Script JS / Portugol / Lua**.

1. **JavaScript**: cria `res://scripts/meu_script.js`, tenta vincular ao nó e exibe `WMK_JS_OK` na execução.
2. **GDScript**: cria um `.gd` nativo.
3. **Portugol**: cria um `.por`, chama o Python para converter a `.gd` e tenta vincular o resultado ao Node2D. Requer Python `py -3` ou `python`, e somente o subconjunto WMK Portugol atual.
4. **Lua**: cria `.lua`, mas exige instalar a Lua GDExtension no próprio projeto. Não é integrado ao editor globalmente.

Se já existir um script no nó, **o plugin não o substitui**.

## Limitações confirmadas

- Script JS `.js` é reconhecido pelo GodotJS nos testes headless; porém, a anexação via GUI e o plugin novo ainda necessitam testes visuais.
- TypeScript `.ts` continua precisando de compilação `tsc`.
- Portugol converte para GDScript, não cria uma nova `ScriptLanguage`.
- Uma extensão Lua GDExtension registrada em outro projeto não habilita Lua automaticamente no projeto atual.
- O plug-in de criação de scripts por projeto é um **contorno funcional proposto**, ainda não uma correção do menu nativo do Godot.

## Critério de aprovação

Executar no Windows uma cena com JS criada via plugin e marcador `WMK_JS_OK`; converter Portugol e obter `WMK_PORTUGOL_OK`; carregar Lua com sua GDExtension e obter `WMK_LUA_54_OK`. Só então anunciar suporte visual como homologado.

## Diagnóstico

Abra **Saída** e **Depurador** no Godot. Se a criação do arquivo ocorrer mas o script não for anexado, envie o erro completo. Não troque a extensão `.ts` para `.js` no criador nativo; utilize o menu WMK.

## Alternativa sem plugin

O pacote compilado pelo GitHub Actions contém projetos JavaScript e Lua de demonstração. Experimente-os antes de modificar projetos de produção.
