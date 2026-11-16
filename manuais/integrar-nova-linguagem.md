<p align="center"><img src="../branding/wmk-codeverse-icon.svg" width="150" alt="WMK CodeVerse"></p>
<h1 align="center">Manual do Desenvolvedor — Como adicionar sua linguagem ao Godot</h1>
<p align="center"><strong>Da API C++ ao script que controla um nó da cena</strong></p>

**Autor:** Walney Moreira Klein — walneyk@hotmail.com

> **Guia de arquitetura e implementação.** Os fragmentos C++ abaixo são pseudocódigo orientativo baseados nas APIs do Godot 4.x; não formam um módulo compilável por si só. A integração de cada runtime exige código específico. Para compilar, use a versão da engine e extensão correspondentes.

## Módulo 1 — Compreender o motor existente

A API do Godot é escrita predominantemente em C++. Os scripts não duplicam a lógica de física, editor e renderização: eles fazem chamadas à API do motor. O Godot tem a interface **`ScriptLanguage`** e abstrações **`Script`** e **`ScriptInstance`**.

No código-fonte, procure:
- `core/object/script_language.h` — `ScriptServer`, `ScriptLanguage` e `Script`.
- `core/object/script_instance.h` — interface de instância de script.
- `modules/gdscript/register_types.cpp` — inicialização de GDScript.
- `modules/mono/register_types.cpp` — registro da linguagem C#.
- `modules/mono/config.py` — dependências e habilitação.
- `modules/mono/SCsub` — integração no SCons.

Exemplo de registro **simplificado**:

```cpp
// Pseudocódigo: pressupõe uma implementação real da classe MinhaLanguage.
static MinhaLanguage *linguagem = nullptr;

void initialize_minha_linguagem(ModuleInitializationLevel level) {
    if (level != MODULE_INITIALIZATION_LEVEL_SCENE) return;
    linguagem = memnew(MinhaLanguage);
    ScriptServer::register_language(linguagem);
}

void uninitialize_minha_linguagem(ModuleInitializationLevel level) {
    if (level != MODULE_INITIALIZATION_LEVEL_SCENE) return;
    ScriptServer::unregister_language(linguagem);
    memdelete(linguagem);
    linguagem = nullptr;
}
```

**Por que só esse registro não basta?** O motor reconheceria a linguagem, mas não saberia executar, validar, criar instâncias, converter propriedades nem carregar scripts.

## Módulo 2 — Escolher a integração certa

### Opção A: a linguagem deve aparecer como script no editor

Escolha uma implementação que exponha `ScriptLanguage` e objetos `Script`/`ScriptInstance`. É o cenário de JS/TS via GodotJS, Lua via extensões especializadas e GDScript. O trabalho inclui instanciar classes em nós e conectar o runtime ao ciclo de vida do Godot.

### Opção B: código nativo quer controlar nós e criar classes

Use **GDExtension** se a linguagem possui FFI e uma integração estável com a API de extensão do Godot. É comum com **C++** (godot-cpp) e **Rust** (gdext). O usuário compila uma biblioteca compartilhada; isso não significa que arquivos `.rs` ou `.cpp` serão interpretados dentro do editor.

### Opção C: precisa modificar o núcleo da engine

Use um **módulo C++** em `modules/nome_do_modulo`, compilado com o código-fonte Godot. Esse caminho aumenta o custo de manutenção e deve ser justificado por limitações reais de GDExtension.

## Módulo 3 — Projeto mínimo de um módulo nativo

Estrutura conceitual:

```text
modules/minhalinguagem/
├── SCsub
├── config.py
├── register_types.h
├── register_types.cpp
├── minha_language.h/.cpp
├── minha_script.h/.cpp
├── minha_instance.h/.cpp
└── runtime/ (runtime e ponte da linguagem)
```

`config.py` define se pode compilar na plataforma, opções e dependências. `SCsub` adiciona os arquivos necessários ao SCons. `register_types.cpp` registra a linguagem no estágio de inicialização adequado.

**A implementação real deve tratar** carregamento/salvamento de recursos de script, validação, métodos, propriedades, instanciamento, referências, conversão `Variant`, mensagens de erro e finalização do runtime.

## Módulo 4 — A ponte entre sua linguagem e o Godot

Fluxo típico:

```text
script minha_linguagem
   ↓ chama set_position / propriedade
runtime/VM da linguagem
   ↓ binding + conversão de tipos
Godot ObjectDB / MethodBind / Variant
   ↓
Node3D (C++ do Godot)
   ↓
SceneTree atualiza e renderiza
```

Condições a tratar:
- **Tipos:** números, strings, arrays, dicionários, objetos, `Vector3`, `Transform3D`, `Callable`.
- **Referências:** objetos derivados de `RefCounted` e nós pertencentes à árvore têm ciclos de vida diferentes.
- **Sinais:** conectar callbacks e desconectar ao liberar o objeto.
- **Threading:** chamadas de cena devem respeitar as restrições de thread do Godot.
- **Erros:** informar script, função, linha e stack trace.
- **Segurança:** não permitir que scripts não confiáveis tenham acesso irrestrito a arquivos, comandos ou rede.

## Módulo 5 — Linguagem por linguagem

### JavaScript e TypeScript
Estude o [GodotJS](https://github.com/godotjs/GodotJS). O módulo implementa a ponte JS ↔ API Godot; TS normalmente usa transpilation para JS. Compare o código do módulo com a versão exata do Godot escolhida. Não basta copiar sua pasta para `modules/`: é preciso satisfazer dependências, compilar e testar.

### Lua
Estude uma Lua GDExtension que registre scripts como linguagem. Confira runtime (Lua 5.4 vs LuaJIT), API do plugin, artefatos para Windows/Linux/Web e como declarar arquivos `.lua`. O fato de o projeto abrir não comprova a execução da linguagem.

### Python
Pesquise bindings como [py4godot](https://github.com/niklas2902/py4godot). A integração de CPython envolve distribuição do interpretador, bibliotecas nativas, dependências Python, caminhos de importação e exportação. Compare compatibilidade com sua versão do Godot; não prometa Python no editor antes de validar.

### C++
O Godot **já permite C++** por módulos nativos e pelo [godot-cpp](https://github.com/godotengine/godot-cpp). Um módulo altera a engine e exige nova compilação. Uma GDExtension oferece classes ao jogo sem reconstruir o motor.

### Rust
Use [gdext](https://github.com/godot-rust/gdext), que permite criar GDExtensions e compilar bibliotecas com Cargo. APIs e suporte à versão Godot mudam; fixe versões e teste cada plataforma.

## Módulo 6 — Compilar e validar

Para módulos C++, o fluxo geral é:

```powershell
py -m pip install scons
scons platform=windows target=editor arch=x86_64
```

**Atenção:** esse comando não acrescenta linguagem nenhuma automaticamente. A integração precisa estar no código e habilitada nas opções do módulo; editor, runtime e templates devem ser compatíveis.

Checklist obrigatório:
1. Editor abre e indica corretamente a linguagem.
2. Criação de script e carregamento dos arquivos da extensão.
3. Método de inicialização chamado (por exemplo, `_ready`).
4. Script muda propriedade de `Node3D`.
5. Script recebe `delta` em `_process` e `_physics_process`.
6. Funcionamento de `Vector3`, `Dictionary`, sinais e recursos.
7. Erros reportam contexto e linha.
8. Troca de cenas, reinicialização e liberação de recursos sem crash.
9. Jogo **exportado** roda com a mesma linguagem.
10. Projeto mantém compatibilidade com GDScript e C# já existentes.

## Módulo 7 — Testes automatizados

Crie projetos pequenos e independentes por linguagem. Cada um deve produzir um marcador identificável:

```text
WMK_GDSCRIPT_OK
WMK_CSHARP_OK
WMK_JS_OK
WMK_TS_OK
WMK_LUA_OK
```

O workflow deve rodar cada projeto com o editor ou template apropriado, verificar o código de saída e procurar o marcador, falhando caso não seja encontrado.

Também é útil testar **projeto misto**, em que uma cena GDScript emite um sinal que um componente de outra linguagem recebe. Não assuma que interoperabilidade está comprovada só porque as linguagens funcionam separadamente.

## Módulo 8 — Documentação, licenças e manutenção

Exija dos contribuintes:
- Versão da engine, do runtime e da integração.
- Lista de plataformas realmente testadas.
- Instruções reproduzíveis, sem segredos nem tokens.
- Licenças do runtime, bindings e dependências.
- Tutorial «Hello World», cena de movimentação e exportação.
- Matriz de CI por linguagem/plataforma.
- Política para segurança de scripts externos.

### Quando aceitar contribuição de outra linguagem?

Quando houver **código reproduzível, compilação bem-sucedida, script de cena executado e documentação**, e não apenas prova de conceito isolada.

## Exercício prático recomendado

Para aprender sem escrever runtime do zero, estude o registro de C# em `modules/mono/register_types.cpp`, depois compare a implementação de `ScriptLanguage` de GDScript e de GodotJS. Documente como uma função `_ready` atravessa runtime/binding até o nó do Godot.

**Leitura seguinte:** [Validação e publicação](validacao-e-publicacao.md).
