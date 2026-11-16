"use strict";
const { CharacterBody2D, Input, Vector2 } = require("godot");

// Anexe ao CharacterBody2D. As acoes estao em project.godot.
exports.default = class Jogador2D extends CharacterBody2D {
    velocidade = 240.0;

    _ready() {
        console.log("WMK_PLAYGROUND_2D_OK");
    }

    _physics_process(_delta) {
        const direcao = Input.get_vector(
            "mover_esquerda",
            "mover_direita",
            "mover_cima",
            "mover_baixo"
        );
        this.velocity = new Vector2(
            direcao.x * this.velocidade,
            direcao.y * this.velocidade
        );
        this.move_and_slide();
    }
};
