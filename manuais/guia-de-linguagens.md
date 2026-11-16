<p align="center"><img src="../branding/wmk-codeverse-icon.svg" width="140" alt="WMK CodeVerse"></p>
<h1 align="center">Manual de Linguagens — Um Motor, Diferentes Caminhos</h1>

**Projeto WMK CodeVerse** · Walney Moreira Klein — walneyk@hotmail.com

## Princípio

A física, renderização e a maior parte das classes do Godot são escritas em C++. Ao adicionar outra linguagem, não reescrevemos `Node3D`, `Vector3` ou `CharacterBody3D`: criamos **bindings**, isto é, uma ponte que permite chamar a API da engine.

As integrações têm três padrões principais:

1. **Linguagem registrada como ScriptLanguage:** arquivo de script anexado ao nó, métodos `_ready`/`_process`, propriedades e editor integrados.
2. **GDExtension:** código de extensão carrega biblioteca nativa e registra classes; algumas extensões também registram uma linguagem de script.
3. **Módulo nativo compilado:** código C++ integrado ao executável na compilação do motor; adequado quando precisamos alterar sistemas internos.

## Situação das linguagens

| Linguagem | Forma comum de integração | O que não devemos prometer |
|---|---|---|
| GDScript | Módulo padrão | Não precisa código separado |
| C# | Módulo Mono/.NET + `GodotSharp` | Editor padrão ≠ editor .NET |
| JavaScript | GodotJS, QuickJS/V8 | Não funciona nativamente sem a integração |
| TypeScript | GodotJS + compilação para JS | TS não é normalmente executado diretamente |
| Lua | Lua GDExtension com runtime Lua | Extensão deve corresponder à versão/plataforma |
| C++ | GDExtension (godot-cpp) ou módulo | Compilação necessária para atualizar a biblioteca |
| Rust | godot-rust/gdext + Cargo | Não é uma linguagem ScriptLanguage por padrão |
| Python | Integração comunitária (ex.: py4godot) | Verificar versão e suporte a exportação |

## Mesmo conceito em duas linguagens oficiais

**GDScript:**
```gdscript
extends Node3D

func _process(delta: float) -> void:
    rotate_y(delta)
```

**C#:**
```csharp
using Godot;

public partial class Girar : Node3D
{
    public override void _Process(double delta)
    {
        RotateY((float)delta);
    }
}
```

A assinatura das APIs varia por linguagem: GDScript usa `rotate_y` e C# usa `RotateY`. Exemplo válido pressupõe editor Godot .NET configurado para C#.

## O que uma linguagem precisa oferecer ao usuário

- Criar e reconhecer arquivos de script, com extensão não ambígua.
- Vincular classe/script a um nó e instanciar a classe.
- Expor propriedades e sinais ao Inspector.
- Chamar métodos do ciclo de vida com segurança.
- Converter valores entre linguagem e `Variant`/tipos do Godot.
- Rastrear erros com arquivo, linha e stack trace.
- Evitar vazamentos e referências inválidas ao liberar objetos.
- Exportar o jogo para cada plataforma anunciada.
- Documentar suporte a threads, editor, ferramentas e depuração.

## Ferramentas e links

- [API Godot](https://docs.godotengine.org/en/stable/classes/index.html)
- [Godot .NET](https://docs.godotengine.org/en/stable/tutorials/scripting/c_sharp/index.html)
- [GodotJS](https://github.com/godotjs/GodotJS)
- [GDExtension](https://docs.godotengine.org/en/stable/tutorials/scripting/gdextension/index.html)
- [godot-cpp](https://github.com/godotengine/godot-cpp)
- [gdext para Rust](https://github.com/godot-rust/gdext)
- [py4godot](https://github.com/niklas2902/py4godot)

> Estes links indicam tecnologias para estudo, **não** garantem suporte integrado ao build atual do WMK CodeVerse.

Próximo passo: [Como integrar uma nova linguagem](integrar-nova-linguagem.md).
