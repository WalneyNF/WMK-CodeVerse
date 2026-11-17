# WMK CodeVerse 4.6.1 — Laboratório de Jogos

**Walney Moreira Klein — walneyk@hotmail.com**

Esta edição prioriza **criar e testar jogos JavaScript (.js) e Portugol (.por)**, mantendo a base 4.6.1 que já compilou corretamente no GitHub Actions [43912110780](https://github.com/WalneyNF/WMK-CodeVerse/actions/runs/43912110780).

- [Pacote rápido usando o binário 4.6.1 anteriormente validado](https://github.com/WalneyNF/WMK-CodeVerse/actions/workflows/wmk-pacote-jogos461.yml)
- [Compilação 4.6.1 com JavaScript como linguagem padrão](https://github.com/WalneyNF/WMK-CodeVerse/actions/workflows/wmk-jogos-461.yml)
- [Projetos para abrir e alterar](wmk-js/jogos-iniciais/README.md)

**JavaScript:** na compilação nova, GodotJS é configurado com `use_typescript=no` para dar preferência a `.js` no diálogo nativo de criação. Os dois fluxos exigem testes CI; ainda não comprovam a interface gráfica interativa.

**Portugol:** não é uma ScriptLanguage nativa do Godot. O compilador Python converte um subconjunto para GDScript; o ZIP inclui exemplo executável e um plugin experimental para facilitar a criação.

**Créditos:** Walney Moreira Klein — walneyk@hotmail.com. O motor Godot permanece sob licença MIT, e seus autores devem ser preservados. Nesta edição de estabilidade, a alteração completa de logo e da tela Sobre ficou fora do caminho crítico; não confunda o nome do pacote com uma mudança interna já concluída.

**Não há publicação automática de Release pública até os testes passarem.** Os arquivos aprovados são disponibilizados na área **Artifacts** do workflow.
