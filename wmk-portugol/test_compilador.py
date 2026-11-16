"""Testes automatizados de WMK Portugol."""
import unittest
from compilador import ErroPortugol, compilar


class TestCompilador(unittest.TestCase):
    def test_inicio(self):
        codigo = ("programa\nfuncao inicio()\n{\n"
                  "inteiro vida = 100\nescreva(vida)\n}\n")
        resultado = compilar(codigo)
        self.assertIn("extends Node2D", resultado)
        self.assertIn("func _ready() -> void:", resultado)
        self.assertIn("    var vida: int = 100", resultado)
        self.assertIn("    print(vida)", resultado)

    def test_condicional(self):
        codigo = ("programa\nfuncao inicio()\n{\n"
                  "se (verdadeiro e nao falso)\n{\n"
                  'escreva("verdadeiro nao muda")\n}\n}\n')
        resultado = compilar(codigo)
        self.assertIn("if true and not false:", resultado)
        self.assertIn('print("verdadeiro nao muda")', resultado)

    def test_atualizacao(self):
        resultado = compilar("programa\nfuncao atualizar()\n{\nescreva(delta)\n}\n")
        self.assertIn("func _process(delta: float) -> void:", resultado)

    def test_erro_sintaxe(self):
        with self.assertRaises(ErroPortugol):
            compilar("programa\nfuncao inicio()\n{\ninstrucao_impossivel\n}\n")

    def test_chave_aberta(self):
        with self.assertRaises(ErroPortugol):
            compilar("programa\nfuncao inicio()\n{\nescreva(1)\n")

    def test_senao_nao_implementado(self):
        with self.assertRaises(ErroPortugol):
            compilar("programa\nfuncao inicio()\n{\nsenao\n}\n")


if __name__ == "__main__":
    unittest.main()
