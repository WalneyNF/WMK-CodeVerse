"""WMK CodeVerse - servidor MCP local e somente leitura.

Requisitos: Python 3.10+, pacote 'mcp'.
Execute: python -m pip install -r wmk-ai/requirements.txt
         python wmk-ai/mcp_server.py

O cliente MCP inicia este processo via stdio. Nunca imprime logs em stdout.
"""
from __future__ import annotations

import os
from pathlib import Path

from mcp.server.fastmcp import FastMCP

APP = FastMCP("WMK CodeVerse")
PROJECT_ROOT = Path(os.environ.get("WMK_PROJECT_DIR", ".")).expanduser().resolve()
ALLOWED_SUFFIXES = {".gd", ".cs", ".js", ".ts", ".lua", ".rs", ".cpp", ".h", ".tscn", ".tres", ".godot", ".json", ".md"}
MAX_READ_BYTES = 128 * 1024
MAX_LIST_ENTRIES = 200


def resolve_project_path(relative: str) -> Path:
    """Resolve um caminho dentro do projeto, rejeitando travessia e links externos."""
    candidate = (PROJECT_ROOT / relative).resolve()
    if not candidate.is_relative_to(PROJECT_ROOT):
        raise ValueError("Caminho fora do projeto nao permitido.")
    return candidate


@APP.tool()
def projeto_info() -> dict:
    """Exibe o projeto Godot selecionado no ambiente WMK_PROJECT_DIR."""
    config = PROJECT_ROOT / "project.godot"
    return {
        "pasta": str(PROJECT_ROOT),
        "projeto_godot": config.is_file(),
        "acesso": "somente leitura",
        "limite_arquivo_bytes": MAX_READ_BYTES,
    }


@APP.tool()
def listar_arquivos(subpasta: str = ".") -> list[str]:
    """Lista arquivos reconhecidos do projeto, no maximo 200 por consulta."""
    folder = resolve_project_path(subpasta)
    if not folder.is_dir():
        raise ValueError("A subpasta informada nao existe.")
    result = []
    for item in sorted(folder.iterdir(), key=lambda p: p.name.lower()):
        if item.name.startswith(".") or item.name in {"node_modules", ".godot"}:
            continue
        if item.is_symlink():
            continue
        if item.is_dir() or item.suffix.lower() in ALLOWED_SUFFIXES:
            result.append(item.relative_to(PROJECT_ROOT).as_posix() + ("/" if item.is_dir() else ""))
        if len(result) >= MAX_LIST_ENTRIES:
            break
    return result


@APP.tool()
def ler_codigo(caminho: str) -> str:
    """Le arquivos de texto permitidos, sem alterar o projeto."""
    file = resolve_project_path(caminho)
    if not file.is_file() or file.suffix.lower() not in ALLOWED_SUFFIXES:
        raise ValueError("Arquivo inexistente ou extensao nao permitida.")
    if file.stat().st_size > MAX_READ_BYTES:
        raise ValueError("Arquivo muito grande para leitura MCP.")
    return file.read_text(encoding="utf-8-sig")


@APP.tool()
def listar_cenas(subpasta: str = ".") -> list[str]:
    """Localiza cenas .tscn sem percorrer caminhos externos ou arquivos ocultos."""
    folder = resolve_project_path(subpasta)
    if not folder.is_dir():
        raise ValueError("Subpasta inexistente.")
    scenes = []
    for path in folder.rglob("*.tscn"):
        if any(part.startswith(".") or part == "node_modules" for part in path.relative_to(PROJECT_ROOT).parts):
            continue
        if path.is_symlink() or not path.resolve().is_relative_to(PROJECT_ROOT):
            continue
        scenes.append(path.relative_to(PROJECT_ROOT).as_posix())
        if len(scenes) >= MAX_LIST_ENTRIES:
            break
    return sorted(scenes)


if __name__ == "__main__":
    if not PROJECT_ROOT.is_dir():
        raise SystemExit("WMK_PROJECT_DIR nao e uma pasta valida.")
    APP.run(transport="stdio")
