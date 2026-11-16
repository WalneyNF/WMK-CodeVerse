# WMK CodeBot — Mascote do WMK CodeVerse

**Nome do mascote e personagem de demonstração:** WMK CodeBot  
**Idealização e direção do projeto:** Walney Moreira Klein — walneyk@hotmail.com

O **WMK CodeBot** é o personagem central proposto para demonstrar o WMK CodeVerse: um robô futurista em branco/prata, violeta e ciano, com rosto/visor inspirado na identidade de código `</>` e um emblema na armadura. **Não utilizar o mascote ou logotipo do Godot como rosto do personagem.**

## Material visual aprovado

Foram produzidas duas artes aprovadas na conversa:
- `branding/mascote/wmk-codebot-arte-principal.png`: ilustração de apresentação e identidade do personagem.
- `branding/mascote/wmk-codebot-prancha-modelagem-3d.png`: vistas frontal, três-quartos, lateral, traseira e detalhes de rig/expressões.

**Importante:** as duas imagens em resolução original ainda precisam ser enviadas como arquivos binários ao repositório. Este commit registra sua especificação e o plano de modelagem. Não confundir esta documentação com uma importação de imagens já concluída.

## Uso planejado

1. Protagonista do **Teste Zero**: personagem 3D em terceira pessoa controlado por JavaScript dentro do Godot, usando WASD, câmera orbital, salto e colisão.
2. Personagem educativo de demonstração em **Portugol**, depois da transpilação para GDScript.
3. Mascote dos manuais, site, README e futura interface do assistente WMK PolyCode.
4. Estudo de criação de modelo 3D no Blender dirigido por Codex via MCP, após configurar a conexão.

## Especificações técnicas para o Blender

- Altura artística de referência: aproximadamente 1,40 m (o valor não obriga escala final de jogo).
- Silhueta: cabeça proporcionalmente grande, visor escuro geométrico, grandes fones circulares, tórax compacto, braços articulados e botas volumosas.
- Identidade cromática: branco/prata, violeta, azul-escuro e ciano emissivo.
- Objetos separados: capacete, visor, orelhas/fones, tronco, braço esquerdo/direito, mãos, pernas, pés, capa e LEDs.
- Rig humanoide básico; animações `idle`, `walk`, `run`, `jump`, `turn`.
- Expressões faciais do visor: padrão, feliz, pensando, concentrado e alerta.
- Exportação de cena pelo formato `.glb` e preservação do original `.blend`.
- Validar os triângulos, materiais e texturas na GPU de destino; preferir geometria modular.

A prancha gerada por IA é **referência de estilo**, não um conjunto de vistas ortográficas perfeitamente consistente. Ajustes devem ser feitos no blockout, com conferência visual antes do rig.

## Processo sugerido ao Codex com MCP Blender

1. Conectar Codex ao Blender MCP e validar as ferramentas realmente expostas.
2. Importar as referências visuais aprovadas como imagens de apoio.
3. Construir um blockout 3D com primitivas, mantendo peças nomeadas.
4. Produzir capturas frontal, lateral, traseira e três-quartos e comparar com a arte.
5. Refinar topologia e acabamento, criar materiais e LEDs.
6. Criar armature, pesos, animações e expressões.
7. Exportar `.glb` e importar no Godot.
8. Criar cena `CharacterBody3D` de teste com câmera em terceira pessoa.
9. Executar teste automatizado de carregamento de cena e validar visualmente jogabilidade.
10. Manter scripts, changelog e etapas reversíveis.

## Critério de pronto

Apenas consideraremos o mascote 3D implementado quando houver arquivo `.blend`, exportação `.glb`, rig funcional, cenas de teste e confirmação do personagem operando no Godot. **Nesta etapa ainda é um personagem conceitual, não um modelo 3D já construído.**

**Créditos:** Walney Moreira Klein — walneyk@hotmail.com.
