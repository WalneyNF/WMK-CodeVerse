# Testes e distribuição pública do WMK CodeVerse
**Créditos:** Walney Moreira Klein — walneyk@hotmail.com.

A versão de Windows 64 bits que passou em testes automatizados é a execução [43905108907](https://github.com/WalneyNF/WMK-CodeVerse/actions/runs/43905108907), commit `3fa81fc6`. Compilação do editor, cena JS, instalação da extensão Lua e cena Lua passaram. A execução produz o artefato `WMK-Godot-Five-Languages-Windows`. O artefato de Actions é temporário, expira em 30/11/2026.

**[Abrir o manual HTML com roteiro de testes](testar-codeverse-windows.html)**.

## Publicação para o público

O workflow `.github/workflows/wmk-publicar-preview.yml` utiliza o artefato da execução aprovada e cria uma GitHub Release marcada como **Pre-release** com `WMK-CodeVerse-Windows-Preview.zip`. Consulte a aba [Releases](https://github.com/WalneyNF/WMK-CodeVerse/releases). Publicação depende de o workflow de Release terminar com sucesso; não confundir com o artefato em Actions.

A Release é experimental, não homologada como estável em PCs de usuários. O build do motor e os exemplos de JavaScript/Lua são distintos do `wmk-studio/`, aplicativo web separado.

## Verificações para distribuição

- Baixar o ZIP da Release pública sem autenticação.
- Extrair em uma pasta do Windows, preservando `GodotSharp`.
- Abrir o editor e criar/salvar uma cena.
- Executar `WMK-JS-Demo`: marcador `WMK_JS_OK`.
- Executar `WMK-Lua-Demo`: marcador `WMK_LUA_54_OK`.
- Conferir licença original MIT e créditos Godot.
- Verificar se a edição mais recente do Playground JS 2D/3D já passou seus próprios testes.
