<p align="center"><img src="../branding/wmk-codeverse-icon.svg" width="150" alt="Emblema WMK CodeVerse"></p>
<h1 align="center">WMK CodeVerse — Biblioteca de Manuais</h1>
<p align="center"><strong>Uma engine. Sua linguagem. Seu universo.</strong></p>

**Responsável:** Walney Moreira Klein — walneyk@hotmail.com

> **Importante:** a base deste fork é Godot 4.4 dev. Os recursos multilinguagem adicionais estão em desenvolvimento e precisam de builds e testes; não estão todos presentes na versão original do repositório.

## Escolha por perfil

| Público | Manual | Conteúdo |
|---|---|---|
| Usuário iniciante | [Primeiros passos](primeiros-passos.md) | Conceitos, editor, projeto, cenas, nós, scripts e erros comuns |
| Usuário e programador | [Guia de linguagens](guia-de-linguagens.md) | GDScript, C#, JS/TS, Lua, Python, C++, Rust e diferenças reais |
| Desenvolvedor da engine | [Como integrar uma nova linguagem](integrar-nova-linguagem.md) | Arquitetura ScriptLanguage, ponte nativa, GDExtension, testes, exportação |
| Mantenedor | [Validação e publicação](validacao-e-publicacao.md) | Matriz de testes, licenças, releases, segurança e critérios de pronto |

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
