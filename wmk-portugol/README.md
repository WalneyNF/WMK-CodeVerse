<p align="center"><img src="../branding/wmk-codeverse-icon.svg" width="150" alt="WMK CodeVerse"></p>

# WMK Portugol — programação de jogos em português

**Walney Moreira Klein — walneyk@hotmail.com**

Uma primeira implementação de **transpilador de um subconjunto educacional de Portugol para GDScript 4.x**. O arquivo `.por` é traduzido para `.gd`, que pode ser anexado a um nó **Node2D** e executado pelo Godot.

> Este dialeto inicial é próprio e inspirado em Portugol, **não** é ainda uma implementação compatível com Portugol Studio ou VisuAlg. Não registra uma nova `ScriptLanguage` no editor e ainda não dispõe de depuração de código-fonte Portugol.

## Exemplo de sintaxe

```text
programa
funcao inicio()
{
    inteiro vida = 100
    escreva("Ola CodeVerse!", vida)
    se (vida > 0)
    {
        escreva("Jogador vivo")
    }
}
```

Comandos disponíveis: `programa`, `funcao inicio()`, `funcao atualizar()`, `funcao fisica()`, `inteiro`, `real`, `cadeia`, `logico`, `escreva(...)`, `se (...)`, `enquanto (...)`, `verdadeiro`, `falso`, `nulo`, `e`, `ou`, `nao`, atribuições e chamadas simples de função. **Não há suporte a `senao` nesta versão**. Abra e feche as chaves em linhas separadas.

## Como experimentar (Windows)

Requer Python 3.10+ e uma edição do Godot 4.x.

```powershell
cd D:\Ferramentas\WMK-CodeVerse
py wmk-portugol\compilador.py wmk-portugol\exemplos\ola_mundo.por
py -m unittest discover -s wmk-portugol -p "test_*.py" -v
```

Um arquivo `ola_mundo.gd` será criado junto ao `.por`.

No Godot, crie uma cena com um nó `Node2D`, copie ou importe o arquivo GDScript gerado para o projeto, anexe-o ao nó e execute a cena. O resultado esperado inclui `WMK_PORTUGOL_OK` no painel Output.

## Arquitetura

```text
codigo.por  →  compilador.py  →  codigo.gd
                                      ↓
                             GDScript do Godot
                                      ↓
                              API Godot / C++
```

Essa abordagem permite testar primeiro a sintaxe e as mensagens de erro antes de criar um runtime completo ou uma integração nativa. **A extensão `.por` ainda não aparece no menu nativo de scripts do editor.**

## Próximos passos

1. Analisador léxico e sintático de verdade, com AST e mapeamento de linhas.
2. Compatibilidade explícita com dialetos Portugol Studio e/ou VisuAlg.
3. Variáveis de escopo, funções com parâmetros, listas, `para`, `senao`.
4. Biblioteca educativa para movimentar personagens e trabalhar com sinais e cenas.
5. Editor visual e tradução com pré-visualização e testes no navegador.
6. Integração direta com o editor e estudos de `ScriptLanguageExtension`.
7. Testes usando o próprio binário Godot em CI.

**Estado:** compilador inicial publicado no GitHub; ainda precisa de validação no Godot e não integra automaticamente o runtime do editor.
