<p align="center"><img src="../branding/wmk-codeverse-icon.svg" width="140" alt="WMK CodeVerse"></p>

# WMK CodeVerse — MCP e provedores de IA

**Walney Moreira Klein — walneyk@hotmail.com**

> **Protótipo inicial.** Os arquivos Python foram adicionados, mas ainda não foram executados em um teste integrado com o editor do Godot. Não existe painel de chat interno nesta etapa.

## O que já existe

- `mcp_server.py`: servidor MCP local via **stdio**, com as ferramentas `projeto_info`, `listar_arquivos`, `ler_codigo` e `listar_cenas`.
- `providers.py`: CLI com adaptadores básicos de texto para **Ollama**, **Groq**, **OpenAI** e **Gemini**.
- Segurança inicial: somente leitura, limite de tamanho, escopo da pasta do projeto, sem execução de comandos e sem gravação de chaves.

## Instalação — Windows / PowerShell

```powershell
cd D:\Ferramentas\WMK-CodeVerse
py -m pip install -r .\wmk-ai\requirements.txt
$env:WMK_PROJECT_DIR = "D:\MeusJogos\MeuProjetoGodot"
py .\wmk-ai\mcp_server.py
```

O servidor usa **stdio**. Em uso normal, um cliente MCP (IDE/agente) deve iniciar o processo. Não é uma aplicação web e não abre uma tela por conta própria.

**Exemplo de configuração de cliente** (ajuste os caminhos):

```json
{
  "mcpServers": {
    "wmk-codeverse": {
      "command": "py",
      "args": ["D:\\Ferramentas\\WMK-CodeVerse\\wmk-ai\\mcp_server.py"],
      "env": {
        "WMK_PROJECT_DIR": "D:\\MeusJogos\\MeuProjetoGodot"
      }
    }
  }
}
```

O formato pode variar conforme o cliente MCP.

## Teste de IA local (Ollama)

```powershell
$env:WMK_OLLAMA_MODEL = "qwen2.5:7b"
py .\wmk-ai\providers.py ollama "Explique o que e um Node3D"
```

## Testes de provedores online

Para os provedores remotos, configure **o nome do modelo disponível em sua conta** e **a chave** usando variáveis de ambiente:

| Provedor | Chave | Modelo |
|---|---|---|
| Groq | `GROQ_API_KEY` | `WMK_GROQ_MODEL` |
| OpenAI | `OPENAI_API_KEY` | `WMK_OPENAI_MODEL` |
| Gemini | `GEMINI_API_KEY` | `WMK_GEMINI_MODEL` |
| Ollama local | Não exige chave no padrão local | `WMK_OLLAMA_MODEL` |

Exemplo:

```powershell
$env:WMK_GROQ_MODEL = "NOME_DE_MODELO_EXISTENTE"
$env:GROQ_API_KEY = "CHAVE_DA_SUA_CONTA"
py .\wmk-ai\providers.py groq "Explique como funciona um sinal em Godot"
```

Nunca coloque chaves reais no GitHub ou em arquivos de exemplo. Provedores remotos podem ter limites de uso e custos.

## Diferença entre MCP e linguagens

- MCP permite que um **agente de IA utilize ferramentas** e leia arquivos do projeto.
- Provedores executam **modelos de IA**, com ou sem MCP.
- Integração de linguagem permite que **scripts do jogo executem no Godot**, mediante bindings e runtime próprios.

## Próximas versões

1. Testes automatizados de protocolo e de provedores simulados.
2. Painel de IA como plugin do editor, sem alterar o núcleo.
3. Descoberta de modelos e configuração gráfica de API keys.
4. Agentes: Tutor, Revisor, Programador, Otimizador, Documentador e Construtor de Cenas.
5. Propostas de alteração em diff, backup e aprovação humana antes de escrever arquivos.
6. Bridge do editor para inspecionar nós e cenas abertos; permissões por projeto.
7. Controle de tokens, orçamento e histórico de execuções.

**Observação de segurança:** até ferramentas de leitura podem expor conteúdo privado a um cliente MCP ou modelo remoto. Use apenas projetos autorizados e revise as permissões.
