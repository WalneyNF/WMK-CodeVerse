# WMK CodeVerse — Compilação reproduzível e validação

**Idealização do WMK PolyCode:** Walney Moreira Klein — walneyk@hotmail.com.

> Documento técnico aberto. A branch `master` tem base histórica Godot 4.4 dev; o fluxo de cinco linguagens é realizado separadamente na branch `wmk-js-ts-integration`, baixando Godot 4.6.1 stable. Compilar não prova execução de scripts nem exportação.

## 1. Requisitos Windows

- Windows 10/11 x64; Visual Studio com ferramentas de C++ (MSVC).
- Git, Python 3.10+, SCons, Node.js, pnpm e SDK .NET.
- Espaço em disco para fontes, dependências e saída compilada.
- Execute os comandos em PowerShell, com ferramentas disponíveis em `PATH`; prefira um terminal Developer PowerShell do Visual Studio.

Verifique versões:

```powershell
git --version
py --version
scons --version
node --version
pnpm --version
dotnet --info
```

Instale somente os componentes ausentes usando suas distribuições oficiais. Não use tokens, senhas ou credenciais no script de build.

## 2. Obter a branch correta

```powershell
git clone https://github.com/WalneyNF/WMK-CodeVerse.git
cd WMK-CodeVerse
git switch wmk-js-ts-integration
py -m pip install scons
npm install -g pnpm@10.11.0
```

Os scripts deste laboratório ficam em `wmk-js/`. A documentação de Portugol, IA e PolyCode está na branch `master`, e ainda não foi integrada automaticamente ao editor construído nesta branch.

## 3. Compilar a engine experimental no Windows

```powershell
powershell -ExecutionPolicy Bypass -File .\wmk-js\build-five-languages.ps1 -WorkDir D:\Ferramentas\WMK-Godot-Build -Jobs 2
```

O script, como registrado no repositório, faz:

1. Clona `godotengine/godot` no ref `4.6.1-stable` para uma pasta isolada.
2. Clona `WalneyNF/GodotJS`, fixa o commit `b1d8b3f4d4688d216657364ddc53db0813444411` e prepara os submódulos.
3. Executa SCons com `platform=windows target=editor arch=x86_64 module_mono_enabled=yes use_quickjs_ng=yes use_typescript=yes d3d12=no -j 2`.
4. Localiza o executável de editor .NET gerado, verifica sua inicialização em modo headless, gera glue Mono e compila assemblies.
5. Prepara a distribuição `WMK-Godot-Five-Languages` com executável e `GodotSharp`.

Se falhar, registre etapa, linha de erro original, versão das dependências e link para a execução. **Não** altere a versão do GodotJS isoladamente sem testar compatibilidade com a base Godot escolhida.

## 4. Lua é adicionada ao projeto de demonstração

```powershell
powershell -ExecutionPolicy Bypass -File .\wmk-js\install-lua.ps1 -Distribution D:\Ferramentas\WMK-Godot-Build\WMK-Godot-Five-Languages
```

Esse passo instala uma GDExtension Lua no projeto-modelo; Lua **não é compilada diretamente no executável**. Confira se os binários Windows x64 estão presentes e se o plugin e o script de demonstração são efetivamente carregados.

## 5. GitHub Actions — caminho sem compilação local

Na página <https://github.com/WalneyNF/WMK-CodeVerse/actions>, escolha **WMK Godot - GDScript CSharp JS TS Lua**, use a branch `wmk-js-ts-integration`, clique em **Run workflow** e acompanhe os logs por etapa. O arquivo de workflow, presente nessa branch, é a fonte de verdade para os testes e o pacote final.

Um artefato só deve ser divulgado como funcional quando o workflow concluir com sucesso e quando cada cena de teste tiver emitido seu marcador:

```text
WMK_GDSCRIPT_OK
WMK_CSHARP_OK
WMK_JS_OK
WMK_TS_OK
WMK_LUA_54_OK
WMK_PORTUGOL_OK
```

Uma linguagem pode estar compilada sem passar na execução da cena. Portugol, nesta fase, é **transpilado para GDScript** e não faz parte do runtime nativo de cinco linguagens.

## 6. Erros já observados

| Falha | Contexto | Como investigar |
| --- | --- | --- |
| `No loader found for resource: res://welcome.lua` | Teste de Lua em execução anterior | Verificar importação do projeto, instalação da GDExtension, ativação do plugin, DLL e compatibilidade |
| `uint32_t has not been declared` em `SpvBuilder.h` | Workflow geral da base histórica, compilador Windows/Mingw | Conferir versão de glslang, includes e toolchain; tratar separadamente do fluxo GodotJS 4.6.1 |
| Erro em testes Python ou GDScript gerado | Transpilador WMK Portugol | Conferir se o dialeto e o arquivo estão dentro do subconjunto documentado; adicionar testes antes de corrigir |

Não declare um erro corrigido até nova execução confirmar.

## 7. Como testar um jogo real

Crie cena mínima por linguagem; execute em modo headless, capture saída e verifique o marcador. Depois teste a interoperabilidade: cena A controlada por Portugol transpilado, cena B por JavaScript, comunicação por sinais Godot. O teste deve falhar se qualquer uma das cenas não for carregada ou se não houver comunicação. Finalmente, repita no jogo exportado.

O projeto de demonstração misto precisa usar uma instalação do GodotJS realmente compatível com a compilação selecionada. Não é suficiente incluir o arquivo `.js` no disco.

## 8. Licenças, reprodutibilidade e contribuições

Mantenha créditos originais da Godot, GodotJS, extensões e bibliotecas; WMK é uma identidade distinta, não substitui autores de componentes de terceiros. Publique versões, instruções sem segredos, scripts de build, resultados de testes e matriz de compatibilidade. Em um pull request, inclua a reprodução mínima do problema e o antes/depois.

**Documento em evolução.** Não é declaração de que um ZIP Windows final já tenha passado em todos os testes.
