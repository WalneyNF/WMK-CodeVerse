# WMK CodeVerse 4.6.1 — Jogos iniciais

**Walney Moreira Klein — walneyk@hotmail.com**

Abra o arquivo `project.godot` pelo editor WMK. Pressione **F6** com a cena principal aberta ou **F5** para executar o projeto.

- `WMK-Jogo-JavaScript`: script verdadeiro `jogador.js`, sem TypeScript; movimentação com as setas.
- `WMK-Jogo-Portugol`: edite `jogador.por`, converta-o com `WMK-Portugol/compilador.py` e execute o `jogador.gd` gerado. Portugol aqui é um subconjunto educacional, NÃO a linguagem nativa do Godot.

**IMPORTANTE:** não altere `jogador.js` para `.ts`. Para este pacote, os templates padrão são JavaScript.

Exemplo para recompilar Portugol após editar o arquivo, na pasta do pacote:

```powershell
py -3 ".\WMK-Portugol\compilador.py" ".\WMK-Jogo-Portugol\jogador.por" -o ".\WMK-Jogo-Portugol\jogador.gd"
```

Para criar seus próprios scripts no editor, instale WMK Language Kit no seu projeto (veja `WMK-Language-Kit/README.md`). Isso é um assistente experimental, não uma linguagem nativa.
