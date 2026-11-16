# WMK CodeVerse Studio — Biblioteca e Agente de Programação
**Autor:** Walney Moreira Klein — walneyk@hotmail.com.

Aplicativo web local, independente da compilação do motor Godot, para organizar snippets de código de jogos 2D e 3D. Interface HTML/CSS/JS, editor Monaco (CDN), biblioteca JSON em disco e agente IA via servidor Node.js.

## Instalar e abrir (Windows)
1. Instale Node.js 20 ou superior. Não requer Docker nem banco de dados.
2. Baixe a pasta `wmk-studio` deste repositório para seu computador (pode baixar o ZIP da branch).
3. No PowerShell, dentro da pasta, execute `Copy-Item .env.example .env`.
4. Configure suas chaves de IA no arquivo `.env` se desejar usar IA.
5. Execute `node server.mjs` (ou `iniciar-windows.bat`).
6. Acesse **http://127.0.0.1:4178**. O servidor escuta exclusivamente o loopback.
7. Execute `npm test` para verificar API e sintaxe sem instalar dependências.

## Funcionalidades
- Aba de ambiente: 2D, 3D ou Geral; filtro por linguagem e busca textual.
- Editor Monaco com substituto `textarea` se estiver offline; **Monaco requer internet**.
- Criar, salvar, editar, localizar e apagar códigos; persistência em `data/biblioteca.json`.
- Templates de movimentação Godot GDScript/JavaScript e código web; o editor **não executa scripts Godot**.
- Copiar, baixar arquivos e exportar/importar biblioteca JSON.
- Agente CodeBot: enviar código e instruções a **Groq, OpenAI, Gemini ou Ollama**, escolhendo a linguagem; resposta em português.
- Arquivo `.env` **somente no backend**, não servido ao navegador e ignorado pelo Git.

## Segurança e limites
O aplicativo é local, **sem login e sem acesso remoto**; não o exponha à Internet. Os códigos enviados às IAs externas saem de seu computador: revise antes de enviar dados de clientes. Respostas de IA podem conter erros. Modelos/limites e custos dependem dos provedores. Faça backup da pasta `data`. Este agente sugere/transforma textos; não altera automaticamente outros arquivos do PC.

## Estrutura
```text
wmk-studio/
  public/           index.html, styles.css, app.js
  server.mjs        API HTTP, persistência e proxy para IA
  .env.example      modelo de configuração (sem credenciais)
  data/             biblioteca JSON criada automaticamente
  test.mjs          teste local
  iniciar-windows.bat
```
