"""Cliente simples de provedores de IA do WMK CodeVerse.

Somente stdlib. Nao armazena chaves; leitura de variaveis de ambiente.
Uso:
    python wmk-ai/providers.py ollama "Explique o que faz _ready no Godot"
    python wmk-ai/providers.py groq "Explique um erro GDScript"

Nao executa comandos sugeridos pelo modelo nem escreve arquivos.
"""
from __future__ import annotations

import json
import os
import sys
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

SYSTEM = (
    "Voce e um assistente de desenvolvimento de jogos no WMK CodeVerse. "
    "Responda em portugues brasileiro. Diferencie o que sabe do que precisa testar. "
    "Nunca alegue ter alterado arquivos ou executado a engine sem evidencia."
)
TIMEOUT_SECONDS = 90
MAX_RESPONSE_BYTES = 2_000_000

PROVIDERS = {
    "ollama": {
        "url": "http://127.0.0.1:11434/api/chat",
        "model_env": "WMK_OLLAMA_MODEL",
        "default_model": "qwen2.5:7b",
    },
    "groq": {
        "url": "https://api.groq.com/openai/v1/chat/completions",
        "key_env": "GROQ_API_KEY",
        "model_env": "WMK_GROQ_MODEL",
        "default_model": None,
    },
    "openai": {
        "url": "https://api.openai.com/v1/chat/completions",
        "key_env": "OPENAI_API_KEY",
        "model_env": "WMK_OPENAI_MODEL",
        "default_model": None,
    },
    "gemini": {
        "url": "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions",
        "key_env": "GEMINI_API_KEY",
        "model_env": "WMK_GEMINI_MODEL",
        "default_model": None,
    },
}


def ask(provider: str, prompt: str) -> str:
    if provider not in PROVIDERS:
        raise ValueError("Provedor invalido. Use: " + ", ".join(PROVIDERS))
    spec = PROVIDERS[provider]
    model = os.getenv(spec["model_env"], spec["default_model"] or "").strip()
    if not model:
        raise ValueError(f"Defina {spec['model_env']} com um modelo disponivel em sua conta.")
    headers = {"Content-Type": "application/json"}
    if provider != "ollama":
        key = os.getenv(spec["key_env"], "").strip()
        if not key:
            raise ValueError(f"Defina {spec['key_env']} nas variaveis de ambiente.")
        headers["Authorization"] = f"Bearer {key}"
    payload = {
        "model": model,
        "messages": [
            {"role": "system", "content": SYSTEM},
            {"role": "user", "content": prompt},
        ],
        "stream": False,
    }
    request = Request(
        spec["url"],
        data=json.dumps(payload, ensure_ascii=False).encode("utf-8"),
        headers=headers,
        method="POST",
    )
    try:
        with urlopen(request, timeout=TIMEOUT_SECONDS) as response:
            raw = response.read(MAX_RESPONSE_BYTES + 1)
        if len(raw) > MAX_RESPONSE_BYTES:
            raise ValueError("Resposta do provedor acima do limite de seguranca.")
        result = json.loads(raw.decode("utf-8"))
    except HTTPError as exc:
        raise RuntimeError(f"Erro HTTP {exc.code} do provedor {provider}. Verifique modelo, chave e cotas.") from None
    except URLError as exc:
        raise RuntimeError(f"Falha de conexao com {provider}: {exc.reason}") from None
    if provider == "ollama":
        return str(result["message"]["content"])
    return str(result["choices"][0]["message"]["content"])


def main(argv: list[str]) -> int:
    if len(argv) < 3 or argv[1] not in PROVIDERS:
        print("Uso: python wmk-ai/providers.py <ollama|groq|openai|gemini> <pergunta>")
        return 2
    try:
        print(ask(argv[1], " ".join(argv[2:])))
        return 0
    except (ValueError, RuntimeError, KeyError, IndexError, json.JSONDecodeError) as error:
        print(f"ERRO: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
