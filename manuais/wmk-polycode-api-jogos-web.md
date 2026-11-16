# WMK PolyCode — APIs para jogos, sites e bancos de dados

**Guia intermediário/avançado — v0.1**  
**Idealização:** Walney Moreira Klein — walneyk@hotmail.com

## 1. Sim: um site pode consumir dados de um jogo

Exemplos: ranking público, conquistas, inventário, estatísticas de jogadores, histórico de partidas e painéis administrativos.

~~~text
                 +-------------------+
Jogo Godot ----->| Backend HTTP API  |----> MySQL/MariaDB
                 | auth + regras     |----> PostgreSQL/Supabase
Site HTML/JS --->| validação + logs  |
                 +-------------------+
~~~

A API deve ser o contrato compartilhado. Para dados competitivos, **não confie em informações produzidas livremente pelo cliente**: pontuações, moedas e inventários precisam ser verificadas pelo servidor. Não distribua senha de banco no executável do jogo nem chave secreta Supabase no JavaScript do site.

## 2. Modelo de endpoints proposto

| Método | Endpoint | Acesso | Finalidade |
| --- | --- | --- | --- |
| GET | /api/v1/status | Público | Saúde do backend |
| GET | /api/v1/ranking | Público ou filtrado | Ranking validado |
| GET | /api/v1/jogadores/{id}/perfil | Autenticado/conforme privacidade | Perfil do jogador |
| GET | /api/v1/inventario | Autenticado | Inventário do usuário da sessão |
| POST | /api/v1/partidas/resultado | Autenticado + validação no servidor | Registrar resultado |
| POST | /api/v1/admin/itens | Administrador | Gerenciar catálogo |

Isto é uma **especificação sugerida**, não endpoints existentes no WMK CodeVerse.

## 3. Laboratório PHP + MariaDB/MySQL com PDO

### Passo 1 — Criar tabela (ambiente de testes)

~~~sql
CREATE TABLE jogadores (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    apelido VARCHAR(60) NOT NULL,
    pontos INT UNSIGNED NOT NULL DEFAULT 0
);
INSERT INTO jogadores (apelido,pontos)
VALUES ('Heroi WMK',120),('Arqueira',80);
~~~

### Passo 2 — Configurar variáveis de ambiente do servidor

- WMK_DB_DSN: exemplo mysql:host=127.0.0.1;dbname=wmk_game;charset=utf8mb4
- WMK_DB_USER: usuário com privilégios mínimos de leitura no laboratório
- WMK_DB_PASS: senha do banco, no ambiente do backend; **não** no projeto do jogo

### Passo 3 — Criar api/ranking.php

~~~php
<?php
header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store');
try {
    $pdo = new PDO(
        getenv('WMK_DB_DSN'),
        getenv('WMK_DB_USER'),
        getenv('WMK_DB_PASS'),
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );
    $stmt = $pdo->query(
        'SELECT apelido, pontos FROM jogadores ORDER BY pontos DESC LIMIT 10'
    );
    echo json_encode(
        ['ranking' => $stmt->fetchAll(PDO::FETCH_ASSOC)],
        JSON_UNESCAPED_UNICODE | JSON_THROW_ON_ERROR
    );
} catch (Throwable $e) {
    http_response_code(500);
    error_log($e->getMessage());
    echo json_encode(['erro' => 'falha_interna']);
}
~~~

Requer PHP com a extensão PDO MySQL habilitada. Não mostre exceções do banco ao público. Em produção, configure TLS, autenticação para dados privados, autorização, limitação de consultas e logs. O servidor embutido PHP serve **apenas para desenvolvimento local**.

### Passo 4 — Testar localmente

~~~powershell
php -S 127.0.0.1:8787 -t api
~~~

Acesse http://127.0.0.1:8787/ranking.php. Verifique que o JSON possui a propriedade ranking. Se der erro, confira as variáveis de ambiente e PDO.

### Passo 5 — Consumir no site HTML/JavaScript

~~~html
<ul id="ranking"></ul>
<script>
async function carregarRanking() {
  const resposta = await fetch("http://127.0.0.1:8787/ranking.php");
  if (!resposta.ok) throw new Error("HTTP " + resposta.status);
  const dados = await resposta.json();
  const lista = document.querySelector("#ranking");
  lista.replaceChildren();
  for (const jogador of dados.ranking) {
    const item = document.createElement("li");
    item.textContent = jogador.apelido + ": " + jogador.pontos;
    lista.appendChild(item);
  }
}
carregarRanking().catch(console.error);
</script>
~~~

O navegador pode exigir CORS se o site e a API usarem origens diferentes. Em produção, prefira hospedar site e API na mesma origem ou aplicar CORS de forma restrita e explícita. Use textContent em vez de innerHTML com dados vindos da rede.

### Passo 6 — Consumir no Godot GDScript

Na cena, crie um nó Node com filho HTTPRequest e anexe este script ao pai:

~~~gdscript
extends Node
@onready var http: HTTPRequest = $HTTPRequest

func _ready() -> void:
    http.request_completed.connect(_resposta)
    var erro := http.request("http://127.0.0.1:8787/ranking.php")
    if erro != OK:
        push_error("Não foi possível iniciar requisição")

func _resposta(resultado: int, status: int,
        _headers: PackedStringArray, body: PackedByteArray) -> void:
    if resultado != HTTPRequest.RESULT_SUCCESS or status != 200:
        push_error("Falha ao obter ranking")
        return
    var dados = JSON.parse_string(body.get_string_from_utf8())
    if typeof(dados) != TYPE_DICTIONARY or not dados.has("ranking"):
        push_error("Resposta inesperada")
        return
    print("WMK_API_RANKING_OK ", dados["ranking"])
~~~

Teste o exemplo no Godot **antes** de adaptar ao Portugol. Ao expandir o transpilador, faça a conversão para chamadas HTTP com tratamento de erro e callbacks.

## 4. E com Supabase?

- O Supabase usa PostgreSQL e oferece APIs e autenticação.
- Para chamadas diretas do cliente, use apenas configurações destinadas a acesso público e políticas Row Level Security adequadas.
- Service role/secret keys e operações privilegiadas devem ficar no backend/Edge Functions, nunca no executável nem num site estático.
- Projete regras de quem pode ler e alterar cada linha; não confunda autenticação com autorização.

## 5. MVP de um painel web para o jogo

- Página de status e disponibilidade do servidor.
- Ranking com paginação e filtros.
- Perfil e conquistas mediante autenticação.
- Admin para visualizar eventos e erros.
- Documentação OpenAPI para APIs existentes.
- Webhooks/eventos assinados para atualizações assíncronas.

## 6. Regras de segurança obrigatórias

1. HTTPS em produção; credenciais armazenadas somente no servidor.
2. Consultas parametrizadas PDO para valores controlados pelo usuário.
3. Validação de entrada, permissões por recurso e limites por usuário/IP.
4. Nunca confiar no cliente para saldo, pontuação ou itens valiosos.
5. Proteção contra replay de transações e duplicidade de eventos.
6. Não colocar segredo administrativo de MySQL/Supabase em jogo, página web ou GitHub.
7. Backups, migrações versionadas, logs e métricas de saúde.
8. Mínimo de dados pessoais e política de retenção aplicável.

## 7. Como contribuir

Entregue um endpoint documentado, teste local, autenticação/autorização, exemplo consumidor Godot, exemplo consumidor web e instruções de implantação. Informe explicitamente o que foi testado e o que ainda é apenas projeto.

**Estado:** este é um tutorial e uma arquitetura proposta. Não existe ainda no WMK CodeVerse uma API de ranking pública hospedada por nós.

**Referências internas:** [runtime e bindings](wmk-polycode-runtime-sdk.md), [PolyCode Academy](wmk-polycode-academy-integracoes.html), [compilação reproduzível](compilacao-reproduzivel-wmk.md).

**Créditos:** Walney Moreira Klein — walneyk@hotmail.com.
