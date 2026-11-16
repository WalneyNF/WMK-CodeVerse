# Migração do WMK CodeVerse para Godot 4.7.2

**Walney Moreira Klein — walneyk@hotmail.com**

## Separação entre motor original e modificações WMK

A branch `wmk-godot-4.7-upgrade` deriva de `wmk-js-ts-integration` e **não substitui** a distribuição 4.6.1.

O script `wmk-js/build-five-languages.ps1` executa a seguinte sequência:

1. Clona `https://github.com/godotengine/godot.git`, tag `4.7.2-stable`, numa pasta própria `godot-4.7.2`.
2. Clona `WalneyNF/GodotJS` no commit fixado pelo script e baixa dependências.
3. Aplica `wmk-js/apply-wmk-branding.ps1` à cópia *local* do código do Godot: versão/nome WMK, tela Sobre, ícones, templates e preferência por `.js`.
4. Gera imagens/ícones, compila C++ com SCons, prepara .NET, testa cenas JS e Lua e empacota o EXE.
5. Disponibiliza **Artifacts** no Actions. **Não publica Release automaticamente até homologação**.

## Por que usar uma branch separada?

A extensão GodotJS usada é a mesma versão anteriormente testada com Godot 4.6.1. O suporte a 4.7.2 **ainda não foi comprovado**. A aplicação dos patches e o build podem falhar por mudanças de API, nomes de classes, estrutura de pastas ou templates. Falhas no CI devem ser investigadas antes de uma Release.

## Como compilar

No GitHub: **Actions → WMK CodeVerse - Migracao Godot 4.7.2 → Run workflow** e escolha a branch `wmk-godot-4.7-upgrade`.

Localmente no Windows, com Visual Studio C++, Python, SCons, .NET SDK, Node e pnpm:

```powershell
git clone --branch wmk-godot-4.7-upgrade https://github.com/WalneyNF/WMK-CodeVerse.git
cd WMK-CodeVerse
py -m pip install scons
npm install -g pnpm@10.11.0
powershell -ExecutionPolicy Bypass -File .\wmk-js\build-five-languages.ps1 -WorkDir "D:\Ferramentas\WMK-Build-4.7.2" -Jobs 2
```

## Critérios para homologação

- Compilação Windows concluída; abertura do editor Windows com título e tela Sobre WMK.
- Logo, splash e ícones WMK; licença MIT, autores Godot e atribuições mantidas.
- Novo projeto cria e executa `.js` pelo assistente (teste visual).
- Novo projeto compila `.ts` com `tsc`; Lua possui GDExtension; Portugol transpila e roda.
- C#, GDScript e cenas 2D/3D executam sem exceções.
- ZIP de Release testado em outra máquina Windows, com hashes e instruções de uso.
- Permissão `Contents: write` de GitHub Actions validada (o repositório já retornou HTTP 403 em tentativa anterior de publicar Release).

**Não confundir nome/branding atualizado com suporte funcional homologado a todas as linguagens.**
