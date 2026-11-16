"""WMK Portugol (subconjunto educacional) -> GDScript 4.x.

Sintaxe propria inspirada em Portugol. Nao e compativel com todo Portugol Studio.
Walney Moreira Klein — walneyk@hotmail.com
"""
import argparse
import re
import sys
from pathlib import Path

TIPOS = {"inteiro": "int", "real": "float", "cadeia": "String", "logico": "bool"}
PALAVRAS = {"verdadeiro": "true", "falso": "false", "nulo": "null",
            "e": "and", "ou": "or", "nao": "not"}


class ErroPortugol(ValueError):
    pass


def expressao(texto):
    """Substitui palavras-chave sem modificar textos entre aspas."""
    partes = re.split(r'("(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\')', texto)
    for i in range(0, len(partes), 2):
        partes[i] = re.sub(r"\b(?:verdadeiro|falso|nulo|e|ou|nao)\b",
                          lambda m: PALAVRAS[m.group()], partes[i])
    return "".join(partes)


def compilar(codigo):
    resultado = ["# Gerado pelo WMK Portugol", "extends Node2D", ""]
    nivel = 0
    pilha = []
    pendente = False
    achou_programa = False
    achou_funcao = False

    for numero, bruto in enumerate(codigo.splitlines(), 1):
        linha = bruto.strip().rstrip(";").strip()
        if not linha or linha.startswith("//"):
            continue
        if linha == "programa":
            if achou_programa:
                raise ErroPortugol(f"Linha {numero}: programa repetido")
            achou_programa = True
            continue
        if not achou_programa:
            raise ErroPortugol(f"Linha {numero}: esperado 'programa'")
        if linha == "{":
            if not pendente:
                raise ErroPortugol(f"Linha {numero}: chave inesperada")
            nivel += 1
            pilha.append("bloco")
            pendente = False
            continue
        if linha == "}":
            if pendente or not pilha:
                raise ErroPortugol(f"Linha {numero}: fechamento inesperado")
            pilha.pop()
            nivel -= 1
            continue
        if pendente:
            raise ErroPortugol(f"Linha {numero}: faltou abrir bloco com {{")

        iniciar = False
        m = re.fullmatch(r"funcao\s+(inicio|atualizar|fisica)\s*\(\s*\)", linha)
        if m:
            if nivel:
                raise ErroPortugol(f"Linha {numero}: funcao dentro de bloco")
            func = {"inicio": "_ready", "atualizar": "_process",
                    "fisica": "_physics_process"}[m[1]]
            params = "delta: float" if func != "_ready" else ""
            texto = f"func {func}({params}) -> void:"
            iniciar = True
            achou_funcao = True
        else:
            m = re.fullmatch(r"se\s*\((.+)\)", linha)
            if m:
                texto = f"if {expressao(m[1])}:"
                iniciar = True
            elif linha == "senao":
                raise ErroPortugol(f"Linha {numero}: senao ainda nao implementado; utilize se")
            else:
                m = re.fullmatch(r"enquanto\s*\((.+)\)", linha)
                if m:
                    texto = f"while {expressao(m[1])}:"
                    iniciar = True
                else:
                    m = re.fullmatch(r"(inteiro|real|cadeia|logico)\s+(\w+)(?:\s*=\s*(.+))?", linha)
                    if m:
                        valor = f" = {expressao(m[3])}" if m[3] is not None else ""
                        texto = f"var {m[2]}: {TIPOS[m[1]]}{valor}"
                    else:
                        m = re.fullmatch(r"escreva\s*\((.*)\)", linha)
                        if m:
                            texto = f"print({expressao(m[1])})"
                        elif re.fullmatch(r"[\w.]+\s*=\s*.+", linha):
                            texto = expressao(linha)
                        elif re.fullmatch(r"[\w.]+\([^;]*\)", linha):
                            texto = expressao(linha)
                        else:
                            raise ErroPortugol(f"Linha {numero}: comando desconhecido: {linha}")
        if not iniciar and nivel == 0:
            raise ErroPortugol(f"Linha {numero}: comando fora da funcao")
        if iniciar and texto.startswith("func "):
            resultado.append(texto)
        else:
            resultado.append("    " * nivel + texto)
        pendente = iniciar
    if nivel or pendente:
        raise ErroPortugol("Bloco incompleto: confira as chaves")
    if not achou_funcao:
        raise ErroPortugol("Nenhuma funcao encontrada")
    return "\n".join(resultado) + "\n"


def main():
    parser = argparse.ArgumentParser(description="WMK Portugol -> GDScript")
    parser.add_argument("entrada", type=Path)
    parser.add_argument("-o", "--saida", type=Path)
    args = parser.parse_args()
    saida = args.saida or args.entrada.with_suffix(".gd")
    try:
        texto = compilar(args.entrada.read_text(encoding="utf-8-sig"))
        saida.write_text(texto, encoding="utf-8")
    except (ErroPortugol, OSError, UnicodeError) as exc:
        print(f"WMK Portugol: {exc}", file=sys.stderr)
        return 1
    print(f"Gerado: {saida}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
