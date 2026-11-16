"use strict";
const { CharacterBody3D, Input, Vector3 } = require("godot");

exports.default = class Jogador3D extends CharacterBody3D {
    velocidade = 5.0;
    gravidade = 9.8;

    _ready() {
        console.log("WMK_PLAYGROUND_3D_OK");
    }

    _physics_process(delta) {
        const direcao = Input.get_vector(
            "mover_esquerda",
            "mover_direita",
            "mover_cima",
            "mover_baixo"
        );
        const v = this.velocity;
        v.x = direcao.x * this.velocidade;
        v.z = direcao.y * this.velocidade;
        v.y = this.is_on_floor() ? 0 : v.y - this.gravidade * delta;
        this.velocity = new Vector3(v.x, v.y, v.z);
        this.move_and_slide();
    }
};
