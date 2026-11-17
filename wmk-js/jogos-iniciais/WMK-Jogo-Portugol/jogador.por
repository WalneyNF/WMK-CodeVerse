programa
funcao inicio()
{
    escreva("WMK_JOGO_PORTUGOL_OK")
}
funcao atualizar()
{
    real velocidade = 240.0
    se (Input.is_action_pressed("ui_right"))
    {
        position.x = position.x + velocidade * delta
    }
    se (Input.is_action_pressed("ui_left"))
    {
        position.x = position.x - velocidade * delta
    }
    se (Input.is_action_pressed("ui_down"))
    {
        position.y = position.y + velocidade * delta
    }
    se (Input.is_action_pressed("ui_up"))
    {
        position.y = position.y - velocidade * delta
    }
}
