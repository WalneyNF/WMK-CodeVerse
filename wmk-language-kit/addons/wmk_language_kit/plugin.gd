@tool
extends EditorPlugin

# WMK CodeVerse - assistente por projeto. Nao altera ScriptLanguage do Godot.
# Walney Moreira Klein - walneyk@hotmail.com

var dialog: ConfirmationDialog
var language: OptionButton
var filename: LineEdit
var status: Label
var attach_script: CheckBox

func _enter_tree() -> void:
    dialog = ConfirmationDialog.new()
    dialog.title = "WMK CodeVerse - Criar script"
    dialog.min_size = Vector2i(540, 300)
    var layout := VBoxContainer.new()
    dialog.add_child(layout)
    var description := Label.new()
    description.text = "Crie scripts diretamente no projeto (sem modificar a engine)."
    layout.add_child(description)
    language = OptionButton.new()
    language.add_item("JavaScript (.js) - GodotJS", 0)
    language.add_item("GDScript (.gd) - nativo", 1)
    language.add_item("Portugol (.por) - transpilado para GDScript", 2)
    language.add_item("Lua (.lua) - requer GDExtension no projeto", 3)
    layout.add_child(language)
    filename = LineEdit.new()
    filename.placeholder_text = "Nome do arquivo, sem extensao"
    filename.text = "meu_script"
    layout.add_child(filename)
    attach_script = CheckBox.new()
    attach_script.text = "Anexar automaticamente ao no selecionado (quando suportado)"
    attach_script.button_pressed = true
    layout.add_child(attach_script)
    status = Label.new()
    status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    layout.add_child(status)
    get_editor_interface().get_base_control().add_child(dialog)
    dialog.confirmed.connect(_create_script)
    language.item_selected.connect(_update_help)
    add_tool_menu_item("WMK - Criar Script JS / Portugol / Lua", _show_dialog)
    _update_help(0)

func _exit_tree() -> void:
    remove_tool_menu_item("WMK - Criar Script JS / Portugol / Lua")
    if is_instance_valid(dialog):
        dialog.queue_free()

func _selected_node() -> Node:
    var nodes := get_editor_interface().get_selection().get_selected_nodes()
    if nodes.is_empty():
        return null
    return nodes[0]

func _show_dialog() -> void:
    var node := _selected_node()
    if node == null:
        status.text = "Selecione primeiro um no da cena."
    else:
        status.text = "No selecionado: %s (%s)" % [node.name, node.get_class()]
    dialog.popup_centered()

func _update_help(_index: int) -> void:
    if status == null:
        return
    match language.selected:
        0: status.text = "JS puro: o GodotJS precisa estar presente no editor."
        1: status.text = "GDScript: ja integrado ao Godot."
        2: status.text = "Portugol: requer Python e o compilador WMK instalado no projeto."
        3: status.text = "Lua: requer a GDExtension Lua no projeto antes de anexar."

func _create_script() -> void:
    var base := filename.text.strip_edges()
    if not base.is_valid_identifier():
        _feedback("Nome invalido: use letras, numeros e _ (inicie por letra ou _).", true)
        return
    var index := language.selected
    var ext := ["js", "gd", "por", "lua"][index]
    var folder := "res://scripts"
    var result := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
    if result != OK:
        _feedback("Nao foi possivel criar a pasta scripts: codigo %d" % result, true)
        return
    var path := "%s/%s.%s" % [folder, base, ext]
    if FileAccess.file_exists(path):
        _feedback("Arquivo ja existe: " + path + " (nada foi sobrescrito).", true)
        return
    var node := _selected_node()
    var node_type := node.get_class() if node != null else "Node"
    var source := _template(index, node_type, base)
    var file := FileAccess.open(path, FileAccess.WRITE)
    if file == null:
        _feedback("Erro ao gravar: %s" % path, true)
        return
    file.store_string(source)
    file.close()
    get_editor_interface().get_resource_filesystem().scan()
    if index == 2:
        _compile_portugol(path, node)
        return
    if not attach_script.button_pressed or node == null:
        _feedback("Criado: " + path, false)
        return
    if node.get_script() != null:
        _feedback("Criado, mas nao anexado: o no ja possui script.", true)
        return
    if index == 3 and not _has_lua_extension():
        _feedback("Lua criado. Instale a GDExtension Lua neste projeto antes de anexar.", true)
        return
    var script := ResourceLoader.load(path, "Script", ResourceLoader.CACHE_MODE_IGNORE)
    if script == null:
        _feedback("Criado %s, mas nao foi reconhecido como Script. Confirme a integracao %s." % [path, ext], true)
        return
    node.set_script(script)
    _feedback("Criado e anexado: " + path + ". Salve a cena (Ctrl+S).", false)

func _compile_portugol(path: String, node: Node) -> void:
    var converter := ProjectSettings.globalize_path("res://tools/wmk-portugol.py")
    if not FileAccess.file_exists("res://tools/wmk-portugol.py"):
        _feedback("Arquivo .por criado. Falta tools/wmk-portugol.py (rode instalar-wmk-language-kit.ps1).", true)
        return
    if node != null and not (node is Node2D):
        _feedback("Arquivo .por criado. O transpilador atual gera 'extends Node2D'; escolha um no Node2D.", true)
        return
    var outpath := path.get_basename() + ".gd"
    var output: Array = []
    var args := PackedStringArray(["-3", converter, ProjectSettings.globalize_path(path), "-o", ProjectSettings.globalize_path(outpath)])
    var exit_code := OS.execute("py", args, output, true)
    if exit_code != 0:
        output.clear()
        args = PackedStringArray([converter, ProjectSettings.globalize_path(path), "-o", ProjectSettings.globalize_path(outpath)])
        exit_code = OS.execute("python", args, output, true)
    if exit_code != 0:
        _feedback("Portugol salvo, mas o compilador falhou. Verifique Python: " + str(output), true)
        return
    get_editor_interface().get_resource_filesystem().scan()
    if attach_script.button_pressed and node != null and node.get_script() == null:
        var converted := ResourceLoader.load(outpath, "Script", ResourceLoader.CACHE_MODE_IGNORE)
        if converted != null:
            node.set_script(converted)
    _feedback("Portugol compilado para " + outpath + ". Salve a cena.", false)

func _has_lua_extension() -> bool:
    var dir := DirAccess.open("res://addons")
    if dir == null:
        return false
    dir.list_dir_begin()
    while true:
        var name := dir.get_next()
        if name == "":
            break
        if dir.current_is_dir() and name != "." and name != "..":
            var child := DirAccess.open("res://addons/" + name)
            if child == null:
                continue
            child.list_dir_begin()
            while true:
                var item := child.get_next()
                if item == "":
                    break
                if item.ends_with(".gdextension"):
                    return true
    return false

func _feedback(message: String, warning: bool) -> void:
    if warning:
        push_warning("[WMK] " + message)
    else:
        print("[WMK] " + message)
    status.text = message

func _template(index: int, node_type: String, base: String) -> String:
    match index:
        0:
            return '"use strict";\nconst { %s } = require("godot");\nexports.default = class %s extends %s {\n    _ready() {\n        console.log("WMK_JS_OK");\n    }\n};\n' % [node_type, base.to_pascal_case(), node_type]
        1:
            return "extends %s\n\nfunc _ready() -> void:\n    print(\"WMK_GDSCRIPT_OK\")\n" % node_type
        2:
            return 'programa\nfuncao inicio()\n{\n    escreva("WMK_PORTUGOL_OK")\n}\n'
        3:
            return 'local WMK = GDCLASS()\nWMK.extends = %s\nfunction WMK:_ready()\n    print("WMK_LUA_54_OK")\nend\nreturn WMK\n' % node_type
    return ""
