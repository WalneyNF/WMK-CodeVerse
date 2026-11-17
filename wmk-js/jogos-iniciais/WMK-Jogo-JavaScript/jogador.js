"use strict";
const { Node2D, Input, Vector2 } = require("godot");

exports.default = class WMKJogador extends Node2D {
    _ready() {
        console.log("WMK_JOGO_JS_OK");
        console.log("Use as setas do teclado para mover o quadrado.");
    }

    _process(delta) {
        const speed = 240;
        const x = (Input.is_action_pressed("ui_right") ? 1 : 0) -
                  (Input.is_action_pressed("ui_left") ? 1 : 0);
        const y = (Input.is_action_pressed("ui_down") ? 1 : 0) -
                  (Input.is_action_pressed("ui_up") ? 1 : 0);
        this.position = new Vector2(
            this.position.x + x * speed * delta,
            this.position.y + y * speed * delta
        );
    }
};
