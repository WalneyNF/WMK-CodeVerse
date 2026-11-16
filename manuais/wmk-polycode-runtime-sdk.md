# WMK PolyCode — Manual avançado: construindo um runtime

**Idealização e direção:** Walney Moreira Klein — walneyk@hotmail.com  
**Projeto-laboratório:** [WMK CodeVerse](https://github.com/WalneyNF/WMK-CodeVerse)  
**Versão:** 0.1, documento técnico e educacional.

> O runtime universal WMK PolyCode ainda não existe como SDK validado. Este manual descreve como um programador pode construí-lo por etapas. Os diagramas e contratos apresentados são conceituais. A documentação deve acompanhar versões e testes comprovados.

## 1. A diferença entre as abordagens

| Técnica | Responsabilidade | Exemplo |
| --- | --- | --- |
| Transpilação | Gera código-fonte de outra linguagem | Portugol → GDScript |
| Runtime | Executa bytecode ou interpreta instruções | Lua, PHP, QuickJS |
| Binding | Liga valores e objetos do runtime à API Godot | Vector2, Node2D, sinais |
| Integração de linguagem | Reconhecimento e execução de scripts anexados a nós | ScriptLanguage / Script / ScriptInstance |
| API externa | Comunica programas e servidores por protocolos | HTTP/JSON, WebSocket |
| MCP | Ferramentas que agentes de IA podem descobrir e chamar | Inspecionar arquivos, cenas e projetos |

**Primeira decisão:** o objetivo é executar scripts dentro dos nós do Godot ou interagir com outro processo? A segunda opção frequentemente dispensa escrever um runtime novo.

## 2. Onde procurar no código-fonte

- [core/object/script_language.h](https://github.com/WalneyNF/WMK-CodeVerse/blob/master/core/object/script_language.h): ScriptServer, ScriptLanguage e Script.
- [core/object/script_instance.h](https://github.com/WalneyNF/WMK-CodeVerse/blob/master/core/object/script_instance.h): ciclo de vida e chamadas de instância.
- [modules/gdscript/register_types.cpp](https://github.com/WalneyNF/WMK-CodeVerse/blob/master/modules/gdscript/register_types.cpp): como GDScript se registra.
- [modules/mono/register_types.cpp](https://github.com/WalneyNF/WMK-CodeVerse/blob/master/modules/mono/register_types.cpp): exemplo da integração .NET.
- [Documentação GDExtension](https://docs.godotengine.org/en/stable/tutorials/scripting/gdextension/index.html): interface de extensão da engine.

Um módulo C++ integrado à compilação e uma GDExtension não têm acesso idêntico às APIs internas. Consulte a versão escolhida da engine antes de copiar código.

## 3. Pipeline de criação de um interpretador

~~~text
arquivo fonte
  ↓ lexer (reconhece tokens e posições)
tokens
  ↓ parser (valida gramática)
AST (árvore sintática)
  ↓ análise semântica (tipos, nomes, escopos)
interpretação da AST OU compilação para bytecode
  ↓
VM / runtime
  ↓ ligação de chamadas nativas
API da aplicação hospedeira
~~~

**Passo 1 — especificação:** defina palavras-chave, literais, operadores, precedência, funções, erros e regras de escopo. Comece com declaração de variável, soma, comparação e impressão.

**Passo 2 — lexer:** transforme caracteres em tokens com tipo, posição, linha e coluna. Strings exigem escape e delimitação corretos. Teste entradas inválidas, acentuação e blocos incompletos.

**Passo 3 — parser:** construa AST. Inclua nós para literal, identificador, expressão binária, declaração, bloco, condicional, chamada e função. Não se limite a substituir palavras por expressões regulares quando houver estruturas aninhadas.

**Passo 4 — semântica:** crie tabelas de símbolos, verifique nome e tipo das variáveis, parâmetros e valores de retorno. Evite aceitar automaticamente a execução de código arbitrário.

**Passo 5 — runtime:** mantenha estado, pilha de chamadas, alocação, valores, erros e limites de instruções. Uma máquina de bytecode mínima pode ter, conceitualmente:

~~~text
LOAD_CONST 100
STORE vida
LOAD vida
CALL imprimir 1
RETURN
~~~

Essas instruções são um exemplo pedagógico, não uma implementação já existente.

## 4. Construindo a ponte com Godot

~~~text
Runtime da linguagem
      ↓
conversor de tipos ↔ Variant
      ↓
validação de objeto / propriedade / método
      ↓
Object, Node, Callable, Signal e demais APIs Godot
~~~

**Passo 6 — tipos:** converta em ambos os sentidos inteiro, real, bool, String, Array, Dictionary, Vector2/Vector3, null e objetos. Preserve coerência de conversão e reporte tipo incompatível em vez de causar crash.

**Passo 7 — objetos:** não retenha ponteiros inválidos; trate ObjectID, instâncias de Node e objetos RefCounted adequadamente. Observe as regras de ownership, liberação e acesso por threads.

**Passo 8 — métodos e sinais:** valide a existência do método, converta argumentos e retornos, conecte callbacks e desconecte quando a instância for finalizada. Não execute código que altere SceneTree a partir de threads inseguras.

**Passo 9 — ScriptLanguage:** adicione os contratos e as implementações necessárias para expor a linguagem ao editor e criar ScriptInstance por nó. O registro pelo ScriptServer é apenas um dos passos: são necessários também carregadores, salvadores, reconhecimento da extensão, validação, mensagens de erro e compatibilidade com exportação.

Para linguagens existentes, como Lua ou PHP, avalie primeiro a API oficial de incorporação da linguagem. Reimplementar o runtime inteiro geralmente é mais caro e arriscado do que criar bindings para um runtime existente.

## 5. Quando escolher transpilação

O primeiro WMK Portugol usa um subconjunto da linguagem para gerar GDScript. Veja [compilador.py](../wmk-portugol/compilador.py), [exemplos](../wmk-portugol/README.md) e testes.

Etapas de evolução:
1. substituir reconhecimento simplificado por AST;
2. mapear linhas de origem para linhas do arquivo gerado;
3. implementar condições, laços, funções e escopos;
4. automatizar importação e compilação no Godot;
5. fornecer um editor de código com erros em português;
6. executar cena real e também o jogo exportado.

Transpilar não torna automaticamente arquivos .por nativos do Godot.

## 6. Testes mínimos para declarar compatibilidade

- O editor inicia e reconhece um arquivo de script.
- Um script é anexado ao Node2D e executa evento inicial.
- Um script altera uma propriedade de cena comprovavelmente.
- Métodos, sinais, tipos e callbacks funcionam.
- Arquivos inválidos mostram erro com linha original.
- Troca de cena e destruição de objetos não causam travamentos.
- Testes headless registram marcador inequívoco, como WMK_RUNTIME_OK.
- Exportação Windows inclui todas as dependências de runtime.
- Projeto misto com GDScript + outra linguagem comunica sinais.
- Logs registram versões, dependências e resultados reproduzíveis.

**Não basta a compilação C++ terminar:** uma cena real precisa executar o código, com teste do jogo exportado.

## 7. Dicas para reduzir trabalho e facilitar contribuições

- Fixe versões de Godot, runtime, SDK, toolchain e dependências.
- Comece com um projeto mínimo por linguagem antes de integração total.
- Desenvolva testes do parser sem iniciar o Godot; use Godot headless apenas para integração.
- Documente a assinatura e o comportamento de toda API exposta pela ponte.
- Registre erro e linha do código original, não somente da saída gerada.
- Meça overhead de chamadas runtime ↔ Godot; evite converter arrays enormes a cada frame.
- Armazene configurações de ferramentas e modelos em arquivos declarativos, sem credenciais.
- Preserve licenças e avisos originais, incluindo os de runtimes incorporados.
- Documente publicamente o que falhou, o motivo conhecido e como reproduzir.

## 8. Laboratórios para programadores experientes

A. Criar parser de expressões com precedência e testes de AST.  
B. Implementar conversão Vector2 e Dictionary com falhas de tipo.  
C. Construir ScriptInstance que modifica Node2D.  
D. Criar integração por sinais entre dois runtimes.  
E. Medir custo de milhares de chamadas ao binding.  
F. Executar os mesmos testes no editor e num jogo exportado.

**Complementos:** [guia de integração](integrar-nova-linguagem.md), [compilação Windows reproduzível](compilacao-reproduzivel-wmk.md) e [PolyCode Academy: PHP, IA e dados](wmk-polycode-academy-integracoes.html).

**Créditos:** WMK PolyCode — Walney Moreira Klein — walneyk@hotmail.com. Técnicas de compilação, incorporação de runtimes e interfaces da Godot são preexistentes; respeite os créditos de seus respectivos autores.
