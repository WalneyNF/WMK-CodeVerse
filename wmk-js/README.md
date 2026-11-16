# WMK Godot — GDScript, C#, JavaScript, TypeScript e Lua

**Autor:** Walney Moreira Klein — walneyk@hotmail.com.

Esta branch prepara a compilação de uma edição Godot para Windows que usa:
- **GDScript:** integrado nativamente ao Godot.
- **C# (.NET):** módulo `mono` compilado juntamente com assemblies `GodotSharp`.
- **JavaScript:** módulo nativo `GodotJS` com QuickJS-NG.
- **TypeScript:** suporte do GodotJS, com transpilation/build JS no projeto.
- **Lua 5.4:** *GDExtension* do projeto `gilzoide/lua-gdextension`, distribuída dentro do projeto-modelo; não embutida no executável.

## Importante: versão do Godot
O fork histórico `WalneyNF/godot` na branch `master` está em **Godot 4.4 dev**. O script baixa uma base isolada Godot **4.6.1-stable** para compatibilidade com o fork `WalneyNF/GodotJS`. **A base 4.4 não foi modificada**. O código do GodotJS está registrado na branch como submódulo em `modules/GodotJS`; o script seleciona o mesmo commit na base 4.6.1.

## Compilação no GitHub Actions
Entre em **Actions > WMK Godot - GDScript CSharp JS TS Lua**, selecione a branch `wmk-js-ts-integration` e execute **Run workflow**.

O workflow:
1. Instala Python/SCons, .NET SDK, Node e pnpm;
2. Compila Godot 4.6.1, com `module_mono_enabled=yes` e `use_quickjs_ng=yes`;
3. Gera `mono` glue e assemblies C#;
4. Obtém a Lua GDExtension 0.8.2 e prepara `WMK-Lua-Demo`;
5. Inicia uma cena Lua e exige `WMK_LUA_54_OK` no log;
6. Publica o artefato **WMK-Godot-Five-Languages-Windows**, apenas se todas as etapas passarem.

**Os testes C# e JS/TS dentro de projetos ainda precisam ser adicionados:** compilação com flags habilitadas, por si só, não confirma que cada linguagem funciona em uma cena.

## Compilação local — Windows
Requisitos: Visual Studio com C++ para desktop, Python, Git, SCons, Node, pnpm e SDK .NET.

```powershell
py -m pip install scons
npm install -g pnpm@10.11.0
powershell -ExecutionPolicy Bypass -File .\wmk-js\build-five-languages.ps1 -WorkDir D:\Ferramentas\WMK-Godot-Build -Jobs 2
powershell -ExecutionPolicy Bypass -File .\wmk-js\install-lua.ps1 -Distribution D:\Ferramentas\WMK-Godot-Build\WMK-Godot-Five-Languages
```

Abra `WMK-Lua-Demo/project.godot` pelo executável gerado para experimentar Lua. Para novos projetos Lua, copie `addons/lua-gdextension` para a pasta do projeto. O teste usa `welcome.lua`.

## Licenças e atribuições
Godot e GodotJS: consulte os respectivos arquivos LICENSE. Lua GDExtension: MIT; preserve os avisos de licença no pacote de terceiros.

## Estado
- [x] Integração de fonte GodotJS como submódulo do fork
- [x] Workflow Windows para GDScript, .NET, JS e TS
- [x] Instalador e projeto de teste Lua 5.4
- [ ] Compilação integral confirmada
- [ ] Execução do script Lua comprovada pelo workflow
- [ ] Testes C# e JS/TS em cenas
- [ ] Exportação de jogos confirmada

Nenhuma falha de compilação deve ser interpretada como sucesso. Os logs e resultados oficiais ficam no GitHub Actions.
