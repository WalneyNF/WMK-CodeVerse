# WMK JS Playground — JavaScript dentro do Godot

Autor: Walney Moreira Klein — walneyk@hotmail.com

Dois projetos de demonstração para a edição WMK do Godot com **GodotJS**.

## Exemplos

| Pasta | Recurso | Comandos |
| --- | --- | --- |
| `2d/` | Personagem 2D com colisão | W A S D ou setas |
| `3d/` | Personagem 3D, chão, luz e câmera | W A S D ou setas |

Os exemplos utilizam a API `require("godot")` do GodotJS. São projetos do Godot, não páginas HTML. **Godot oficial sem GodotJS não os executa.**

## Testar no Windows

1. Obtenha o editor personalizado gerado pela execução **WMK Godot - GDScript CSharp JS TS Lua**.
2. Extraia o pacote completo. Se o editor ainda não estiver disponível, aguarde a conclusão da compilação; **não é preciso recompilar o editor para modificar os arquivos .js**.
3. Abra o editor WMK e importe `2d/project.godot` ou `3d/project.godot`.
4. Execute com **F6** (cena atual) ou **F5** (projeto completo).
5. Altere `jogador.js` e execute novamente. Se necessário, reabra a cena para atualizar o script.

## Testes automatizados

No PowerShell, na raiz deste repositório:

```powershell
./wmk-js/test-playground.ps1 -Distribution "D:\Ferramentas\WMK-Godot-Five-Languages"
```

O script testa importação e execução de **ambas** as cenas sem interface gráfica. É um smoke test de carregamento e execução; **não substitui um teste visual nem comprova que o teclado físico e colisões estão perfeitos**.

## Diagnóstico

- `Cannot load script` / `Unknown extension js`: o editor usado não tem suporte GodotJS ou falhou a integração.
- `Invalid call`: incompatibilidade da API JavaScript com a revisão do GodotJS.
- `Missing project.godot`: caminho da pasta de projeto incorreto.
- O personagem não se move: clique na janela do jogo e confirme as ações em **Projeto > Configurações > Input Map**.

**Estado:** estes exemplos foram adicionados como código e precisam passar no teste automatizado da próxima execução do GitHub Actions. A integração básica JS já exibiu `WMK_JS_OK` em uma execução anterior do workflow.
