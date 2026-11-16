# WMK CodeVerse — Windows Preview

**Identidade própria WMK | baseado na Godot Engine 4.6.1 + GodotJS**

**Personalização:** Walney Moreira Klein — walneyk@hotmail.com.

Esta edição passa a gerar `WMK-CodeVerse-editor.exe`, com logo, splash, ícone e texto de personalização em **Sobre**. Permanecem os créditos históricos, autores e licença MIT do Godot. A marca WMK não deve sugerir que esta edição é oficial da Godot Foundation.

## Linguagens

- GDScript: nativa.
- C#: .NET compilado no editor; testes de jogos C# ainda necessários.
- JavaScript: suporte nativo GodotJS; o patch WMK altera a extensão sugerida pelo assistente para `.js`.
- TypeScript: suporte GodotJS; arquivos `.ts` exigem compilação com `tsc` no projeto.
- Lua: GDExtension distribuída em projeto de demonstração; não é uma linguagem global.
- Portugol: transpilação educacional `.por` para `.gd` por um compilador Python; não é uma ScriptLanguage global.

Para testar criação de código use a opção JS padrão ou instale o `WMK-Language-Kit` fornecido no pacote.

## Testes e downloads

Os testes JS 2D/3D e Lua são realizados no workflow Windows. **Build verde não significa que todos os recursos foram homologados visualmente.**

- [GitHub Actions](https://github.com/WalneyNF/WMK-CodeVerse/actions/workflows/wmk-godot-js-windows.yml)
- [Releases](https://github.com/WalneyNF/WMK-CodeVerse/releases)
- [Manual do Language Kit](wmk-language-kit/README.md)
- [Manual de compilação e integração](wmk-js/README.md)

**ATENÇÃO:** a publicação de Releases exige permissão `Contents: Read and write` do GitHub Actions nas configurações do repositório. Se o GitHub responder HTTP 403, o ZIP continuará disponível nos Artifacts.
