extends BaseScreen

func build() -> void:
    var box := add_centered(320)
    box.add_child(lbl("PAWN SHOP", 64, Palette.ACCENT_HOVER, HORIZONTAL_ALIGNMENT_CENTER))
    box.add_child(lbl("Placeholder tagline goes here", 18, Palette.MUTED, HORIZONTAL_ALIGNMENT_CENTER))
    box.add_child(spacer(24))
    box.add_child(btn("New Run", _new_run, Vector2(0, 52)))
    var cont := btn("Continue", _continue, Vector2(0, 52))
    cont.disabled = not Game.has_save()
    box.add_child(cont)
    box.add_child(btn("Settings", _settings, Vector2(0, 52)))
    box.add_child(btn("Quit", _quit, Vector2(0, 52)))

func _new_run() -> void:
    Game.new_run()
    Game.goto("shop")

func _continue() -> void:
    if Game.load_game():
        Game.goto("shop")

func _settings() -> void:
    Game.goto_from("settings", "main_menu")

func _quit() -> void:
    get_tree().quit()
