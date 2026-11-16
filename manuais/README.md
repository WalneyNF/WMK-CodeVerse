<p align="center"><img src="../branding/wmk-codeverse-icon.svg" width="150" alt="Emblema WMK CodeVerse"></p>
<h1 align="center">WMK CodeVerse — Biblioteca de Manuais</h1>
<p align="center"><strong>Uma engine. Sua linguagem. Seu universo.</strong></p>

**Responsável:** Walney Moreira Klein — walneyk@hotmail.com

> **Importante:** a base deste fork é Godot 4.4 dev. Os recursos multilinguagem adicionais estão em desenvolvimento e precisam de builds e testes; não estão todos presentes na versão original do repositório.

## Escolha por perfil

| Público | Manual | Conteúdo |
|---|---|---|
| Integradores e desenvolvedores | [WMK PolyCode Academy: guia HTML](wmk-polycode-academy-integracoes.html) | Tutoriais Portugol, PHP, APIs, IA/MCP e bancos de dados |
| Mantenedores | [Compilação reproduzível](compilacao-reproduzivel-wmk.md) | Comandos Windows, Actions, erros conhecidos, testes e publicação |
| Programador avançado | [Construir runtime e bindings](wmk-polycode-runtime-sdk.md) | Parser, AST, VM, ScriptLanguage, segurança e testes |
| Desenvolvedor web / jogos | [APIs de jogos e sites](wmk-polycode-api-jogos-web.md) | PHP, MySQL/MariaDB, Supabase, ranking, Godot e JavaScript |
| Desenvolvedor e pesquisador | [WMK PolyCode — Documento técnico em HTML](wmk-polycode.html) | Conceito, arquitetura de extensibilidade, adaptadores, linguagens, APIs, IA/MCP, segurança e roteiro de validação |
| Usuário iniciante | [Primeiros passos](primeiros-passos.md) | Conceitos, editor, projeto, cenas, nós, scripts e erros comuns |
| Usuário e programador | [Guia de linguagens](guia-de-linguagens.md) | GDScript, C#, JS/TS, Lua, Python, C++, Rust e diferenças reais |
| Desenvolvedor da engine | [Como integrar uma nova linguagem](integrar-nova-linguagem.md) | Arquitetura ScriptLanguage, ponte nativa, GDExtension, testes, exportação |
| Iniciantes e professores | [WMK Portugol](../wmk-portugol/README.md) | Criar programas em português e transpilar para GDScript |
| Usuários e desenvolvedores de IA | [IA e MCP](ia-mcp.md) | Provedores Ollama, Groq, OpenAI, Gemini e arquitetura MCP |
| Mantenedor | [Validação e publicação](validacao-e-publicacao.md) | Matriz de testes, licenças, releases, segurança e critérios de pronto |

## WMK CodeBot — Mascote oficial

O mascote **WMK CodeBot** será o personagem principal do laboratório de terceira pessoa do CodeVerse. Já estão publicados seu [ícone vetorial simplificado](../branding/mascote/wmk-codebot-icon.svg) e sua [ficha para Blender / Codex + MCP](../branding/mascote/README.md). As duas artes originais geradas ainda precisam ser adicionadas como PNG binários ao repositório.

**Direção:** Walney Moreira Klein — walneyk@hotmail.com.

## WMK PolyCode

**WMK PolyCode** é a iniciativa de arquitetura proposta por **Walney Moreira Klein — walneyk@hotmail.com** para integrar novas linguagens, APIs, MCP e provedores de IA a softwares por meio de adaptadores. O WMK CodeVerse é seu primeiro laboratório. [Leia o documento HTML completo](wmk-polycode.html).

## Estrutura de estudos

**Módulo A — Usuário:** executar o Godot existente, criar uma cena, conectar um script e entender a documentação da API.

**Módulo B — Programador:** escolher como a linguagem acessa os objetos C++ da engine: ScriptLanguage, GDExtension ou módulo compilado.

**Módulo C — Mantenedor:** compilar o editor, gerar templates de exportação e provar que o script roda também no jogo exportado.

## Fontes técnicas

- [Godot — Compilação do código-fonte](https://docs.godotengine.org/en/stable/contributing/development/compiling/index.html)
- [Godot — GDExtension](https://docs.godotengine.org/en/stable/tutorials/scripting/gdextension/index.html)
- [Godot — Editor e suas traduções](https://docs.godotengine.org/pt-br/stable/)
- [GodotJS](https://github.com/godotjs/GodotJS)
- [godot-cpp](https://github.com/godotengine/godot-cpp)
- [godot-rust/gdext](https://github.com/godot-rust/gdext)

Os manuais são documentação do **projeto WMK**, não documentação oficial da Godot Foundation.
