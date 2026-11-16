<p align="center"><img src="../branding/wmk-codeverse-icon.svg" width="145" alt="WMK CodeVerse"></p>
<h1 align="center">WMK CodeVerse — Manual de Validação e Publicação</h1>

**Walney Moreira Klein — walneyk@hotmail.com**

## Regra para uma versão pública

O CodeVerse deve informar explicitamente **quais linguagens funcionam**, em quais sistemas e qual integração é usada. Não anunciar «cinco ou oito linguagens prontas» só porque existem módulos ou extensões no código.

| Linguagem | Compilação | Cena de teste | Export Windows | Export Web |
|---|---|---|---|---|
| GDScript | A verificar no build WMK | A verificar | A verificar | A verificar |
| C# | A verificar no build WMK | A verificar | A verificar | Ver limitações do .NET por versão |
| JS | A verificar | A verificar | A verificar | A verificar |
| TS | A verificar | A verificar | A verificar | A verificar |
| Lua | A verificar | A verificar | A verificar | A verificar |
| Python | Não integrado | Não integrado | Não integrado | Não integrado |
| C++ | Suporte nativo Godot/GDExtension | Requer exemplo | A verificar | A verificar |
| Rust | Não integrado; gdext possível | Não integrado | Não integrado | Não integrado |

## Política de builds

1. Use uma branch para mudanças experimentais.
2. Fixe versões de Godot, módulos, SDKs e dependências.
3. Rode verificação de ambiente antes da compilação.
4. Gere editor e templates para as plataformas que pretende anunciar.
5. Teste `--headless --version` apenas como *smoke test* de inicialização.
6. Teste uma cena real por linguagem.
7. Só publique um ZIP quando todos os testes obrigatórios passarem.
8. Inclua checksum SHA-256, licença, changelog e notas de compatibilidade.

## Idiomas da interface

O Godot já possui traduções de editor. **README traduzido não implica editor traduzido.** Verifique a cobertura pt-BR real antes de anunciar interface 100% em português. Traduções de módulos de terceiros precisam de revisão.

## Integração de novas linguagens

A contribuição deve conter código, documentação, exemplo e testes. Não aceitar módulos que exigem downloads em tempo de execução sem consentimento informado, que introduzam segredos em CI ou cuja licença impeça redistribuição conforme o projeto.

## Informações obrigatórias na release

- Base exata do Godot (tag e commit).
- Commit de cada módulo de terceiros.
- Versões de compilador, .NET, Node e runtimes.
- Sistemas e arquiteturas testados.
- O que foi realmente validado e o que continua experimental.
- Avisos de licença Godot e terceiros.

**Material comunitário WMK CodeVerse; baseado em Godot Engine, projeto independente da Godot Foundation.**
