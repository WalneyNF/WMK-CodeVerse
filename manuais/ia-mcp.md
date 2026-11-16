<p align="center"><img src="../branding/wmk-codeverse-icon.svg" width="140" alt="WMK CodeVerse"></p>

# Manual do Usuário e Desenvolvedor — IA e MCP

**Walney Moreira Klein — walneyk@hotmail.com**

## Conceitos

**Provedor:** serviço que executa o modelo (Ollama, Groq, OpenAI, Gemini).

**Agente:** programa que combina instruções, estado, chamadas a modelos e uso de ferramentas.

**MCP:** protocolo pelo qual clientes descobrem e utilizam ferramentas de um servidor. Não é uma linguagem de programação de jogos.

**API do Godot:** interface de classes, propriedades, métodos e sinais, utilizada por scripts, extensões ou plugins.

## Arquitetura proposta

```text
Desenvolvedor
    |
Painel IA do CodeVerse (a desenvolver)
    +--- Provedores: Ollama / Groq / OpenAI / Gemini
    |
    +--- Cliente MCP
              |
        Servidor MCP WMK (protótipo pronto em código)
              |
        Projeto Godot no disco (somente leitura)
```

O protótipo MCP **não controla o editor em execução**. Ele lê arquivos no disco e requer um cliente MCP compatível.

## Ferramentas iniciais MCP

- `projeto_info`: pasta e presença de `project.godot`.
- `listar_arquivos`: arquivos e subpastas reconhecidos.
- `ler_codigo`: conteúdo de arquivo permitido, limitado a 128 KiB.
- `listar_cenas`: caminhos de cenas `.tscn`.

## Integrando outra IA

O arquivo `wmk-ai/providers.py` define o formato `ask(provedor, prompt)`, que deverá futuramente ser envolvido por um serviço ou painel de editor. Cada adaptador trata autenticação e formato de resposta; o usuário escolhe o modelo.

Atenção à privacidade: não envie automaticamente conteúdo completo de projetos, chaves, documentos pessoais ou código proprietário para serviços remotos.

## Plano de segurança para edição por agentes

Antes de liberar alterações em cenas/código, implementar: lista de arquivos permitidos, autorização por operação, visualização do diff, backup, validação da sintaxe, teste pós-edição e possibilidade de desfazer. Nunca executar comandos sugeridos pelo modelo sem consentimento.

## Como instalar e testar

Consulte [o guia prático de MCP e provedores](../wmk-ai/README.md).

**Estado:** o código inicial está versionado; não há ainda comprovação de conexão com um cliente MCP nem painel visual integrado.
