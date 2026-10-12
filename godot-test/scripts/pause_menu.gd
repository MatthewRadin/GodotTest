extends BaseScreen
## Instanced on top of the shop when Esc is pressed. Pauses the tree.

var status: Label
var opened_at := 0

func _init() -> void:
    bg_color = Color(Palette.BG, 0.9)
    process_mode = Node.PROCESS_MODE_ALWAYS     # keep working while the tree is paused
    opened_at = Time.get_ticks_msec()

func build() -> void:
    var box := add_centered(300)
    box.add_child(lbl("PAUSED", 48, Palette.ACCENT_HOVER, HORIZONTAL_ALIGNMENT_CENTER))
    box.add_child(btn("Resume", _resume, Vector2(0, 48)))
    box.add_child(btn("Save", _save, Vector2(0, 48)))
    box.add_child(btn("Load", _load, Vector2(0, 48)))
    box.add_child(btn("Settings", _settings, Vector2(0, 48)))
    box.add_child(btn("Quit to Main Menu", _quit, Vector2(0, 48)))
    status = lbl("", 16, Palette.MUTED, HORIZONTAL_ALIGNMENT_CENTER)
    box.add_child(status)

func _unhandled_input(event: InputEvent) -> void:
    var key := event as InputEventKey
    if key and key.pressed and not key.echo and key.keycode == KEY_ESCAPE:
        if Time.get_ticks_msec() - opened_at > 200:   # ignore the Esc press that opened us
            _resume()

func _resume() -> void:
    get_tree().paused = false
    queue_free()

func _save() -> void:
    Game.save_game()
    status.text = "Saved."

func _load() -> void:
    if Game.load_game():
        Game.goto("shop")
    else:
        status.text = "No save file found."

func _settings() -> void:
    Game.goto_from("settings", "shop")

func _quit() -> void:
    Game.goto("main_menu")
