<p align="center"><img src="../branding/wmk-codeverse-icon.svg" width="140" alt="WMK CodeVerse"></p>
<h1 align="center">Manual do Usuário — Primeiros Passos no WMK CodeVerse</h1>
<p align="center"><em>Aprenda a criar seu primeiro projeto sem precisar dominar o código-fonte da engine</em></p>

**Créditos:** Walney Moreira Klein — walneyk@hotmail.com

## 1. O que é o WMK CodeVerse?

Uma proposta de distribuição aberta do Godot com suporte a múltiplas linguagens. A **base atual do repositório**, porém, ainda é um fork Godot 4.4 dev. **Não assuma que JS/TS, Lua ou C# estejam disponíveis em qualquer executável Godot que você baixar.** O build .NET é separado e as demais integrações exigem módulos ou extensões compatíveis.

## 2. Antes de começar

- Windows 10/11 ou sistema suportado pelo Godot.
- Uma distribuição do editor compatível com a linguagem que pretende testar.
- Para **GDScript**, o editor padrão é suficiente.
- Para **C#**, use a edição do Godot com .NET e instale um SDK .NET compatível.
- Para **JS/TS**, é preciso um editor efetivamente compilado com GodotJS; TypeScript também usa ferramentas de projeto (Node e gerenciador de pacotes).
- Para **Lua**, uma extensão apropriada deve ser instalada no projeto; não há Lua nativa no Godot padrão.
- **Python**, **C++** e **Rust** não aparecem automaticamente no menu de scripts só por instalar o compilador da linguagem.

## 3. Conheça a interface

| Painel | Serve para |
|---|---|
| Scene | Árvore de nós da cena |
| Inspector | Propriedades do nó selecionado |
| FileSystem | Assets, cenas e scripts no projeto |
| Viewport 2D/3D | Editar o cenário e os objetos |
| Output/Debugger | Logs, erros e inspeção da execução |

Para mudar o idioma da interface: abra **Editor → Editor Settings**, procure **Interface → Editor → Language** (o caminho pode variar com a versão) e selecione **Português (Brasil)**. Reinicie o editor se solicitado. Tradução parcial da interface não significa tradução de todas as bibliotecas e mensagens de terceiros.

## 4. Primeiro projeto em GDScript (funciona no Godot padrão)

1. Abra o editor, clique em **Novo Projeto**, informe o nome `MeuPrimeiroJogo` e uma pasta.
2. Escolha o renderizador compatível com seu computador e crie o projeto.
3. Crie uma **Cena 3D** com nó raiz `Node3D`.
4. Adicione `MeshInstance3D`; no Inspector escolha uma `BoxMesh`.
5. Adicione um nó `Camera3D`, posicionando-o para visualizar a caixa; defina como câmera atual, se necessário.
6. Selecione o `Node3D`, clique em **Anexar Script** e use GDScript.
7. Substitua o conteúdo pelo exemplo:

```gdscript
extends Node3D

@export var velocidade: float = 1.5

func _process(delta: float) -> void:
    rotate_y(velocidade * delta)
```

8. Salve a cena como `principal.tscn`. Defina-a como cena principal e clique em **Executar Projeto (F5)**.

**Resultado esperado:** os filhos 3D do nó raiz giram continuamente. Se a tela ficar preta, confira se a cena tem câmera ativa e algum material/iluminação visível.

## 5. Conceitos essenciais

- **Nó:** unidade de comportamento, como `Node3D`, `CharacterBody3D`, `Camera3D`.
- **Cena:** conjunto reutilizável de nós.
- **Script:** lógica anexada a um nó ou recurso; a linguagem depende do build.
- **Sinal:** mecanismo de comunicação por eventos.
- **`_process(delta)`:** atualizações por frame.
- **`_physics_process(delta)`:** atualizações na taxa fixa da física.
- **`@export`:** propriedades GDScript editáveis no Inspector.

## 6. Como escolher linguagem sem confusão

| Objetivo | Escolha inicial recomendada | Observação |
|---|---|---|
| Aprender Godot | GDScript | Documentação ampla, integrado ao editor |
| Desenvolver com .NET | C# | Precisa editor .NET e SDK |
| Reaproveitar conhecimento web | JS/TS | Depende de GodotJS compatível |
| Scripting em Lua | Lua | Depende de GDExtension, não é nativo no editor padrão |
| Código nativo e performance | C++ / Rust | Exige compilação e ponte nativa |
| Programação Python | Python | Depende de binding/extensão, verifique compatibilidade |

## 7. Solução de problemas

**Não aparece JavaScript no editor?** Você está provavelmente utilizando uma edição sem GodotJS, ou houve falha no registro do módulo. Verifique o build, não apenas o nome do executável.

**A extensão Lua aparece, mas script não executa?** Confirme os arquivos `.gdextension`, bibliotecas nativas por plataforma, registro de `ScriptLanguage` e versão da API.

**C# não compila?** Verifique `dotnet --info`, edição do editor e logs MSBuild; uma distribuição .NET precisa das bibliotecas `GodotSharp`.

**Erro ao exportar?** O export template precisa oferecer os mesmos módulos/bindings que o editor; um script que funciona só no editor não prova que o jogo publicado funcionará.

## 8. Exercícios

1. Alterar `velocidade` no Inspector e observar o efeito.
2. Criar uma segunda cena que reutilize a caixa.
3. Conectar um sinal de botão a um script.
4. Testar a cena no renderizador de compatibilidade.
5. Ler o [Guia de linguagens](guia-de-linguagens.md) antes de instalar extensões.

**Próxima leitura:** [Guia de linguagens](guia-de-linguagens.md) e [Manual do Desenvolvedor](integrar-nova-linguagem.md).
