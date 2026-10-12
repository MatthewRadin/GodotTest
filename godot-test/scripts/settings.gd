extends BaseScreen
## Three tabs: Display, Audio, Controls. Changes are held in `pending`
## until Apply is pressed.

var pending: Dictionary

func build() -> void:
    pending = Game.settings.duplicate()
    main.add_child(lbl("Settings", 40, Palette.ACCENT_HOVER))
    var tabs := TabContainer.new()
    tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
    main.add_child(tabs)
    tabs.add_child(_display_tab())
    tabs.add_child(_audio_tab())
    tabs.add_child(_controls_tab())
    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 12)
    main.add_child(row)
    row.add_child(btn("Back", _back, Vector2(160, 48)))
    row.add_child(btn("Reset to Default", _reset, Vector2(200, 48)))
    row.add_child(btn("Apply", _apply, Vector2(160, 48)))


# ---------------------------------------------------------------- tabs
func _display_tab() -> Control:
    var v := _tab("Display")
    v.add_child(lbl("Screen", 24, Palette.ACCENT_HOVER))
    _row(v, "Fullscreen", _check("fullscreen"))
    _row(v, "Resolution", _option("resolution", ["1280 x 720", "1600 x 900", "1920 x 1080"]))
    v.add_child(lbl("Picture", 24, Palette.ACCENT_HOVER))
    _row(v, "Brightness", _slider("brightness", 0.5, 1.0, 0.05))
    _row(v, "UI scale", _slider("ui_scale", 0.75, 1.5, 0.05))
    v.add_child(lbl("Graphics", 24, Palette.ACCENT_HOVER))
    _row(v, "Asset quality", _option("graphics", ["Low", "Medium", "High"]))
    return v

func _audio_tab() -> Control:
    var v := _tab("Audio")
    v.add_child(lbl("Volume", 24, Palette.ACCENT_HOVER))
    _row(v, "Master", _slider("master", 0.0, 1.0, 0.05))
    _row(v, "Music", _slider("music", 0.0, 1.0, 0.05))
    _row(v, "Sound effects", _slider("sfx", 0.0, 1.0, 0.05))
    v.add_child(lbl("Output", 24, Palette.ACCENT_HOVER))
    var devices := AudioServer.get_output_device_list()
    var dev := OptionButton.new()
    for d in devices:
        dev.add_item(d)
    dev.select(maxi(devices.find(pending["audio_device"]), 0))
    dev.item_selected.connect(func(i: int): pending["audio_device"] = devices[i])
    _row(v, "Output device", dev)
    _row(v, "Mute when tabbed out", _check("mute_unfocused"))
    return v

func _controls_tab() -> Control:
    var v := _tab("Controls")
    v.add_child(lbl("Input", 24, Palette.ACCENT_HOVER))
    _row(v, "Input device", _option("input_device", ["Keyboard + Mouse", "Gamepad (placeholder)"]))
    v.add_child(lbl("Move: WASD / Arrow keys", 18, Palette.MUTED))
    v.add_child(lbl("Interact: E     Inventory: I     Pause: Esc", 18, Palette.MUTED))
    return v


# ---------------------------------------------------------------- widget helpers
func _tab(tab_name: String) -> VBoxContainer:
    var v := VBoxContainer.new()
    v.name = tab_name
    v.add_theme_constant_override("separation", 16)
    return v

func _row(parent: Control, text: String, control: Control) -> void:
    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 16)
    var l := lbl(text, 20)
    l.custom_minimum_size = Vector2(260, 0)
    row.add_child(l)
    row.add_child(control)
    parent.add_child(row)

func _check(key: String) -> CheckBox:
    var c := CheckBox.new()
    c.button_pressed = pending[key]
    c.toggled.connect(func(on: bool): pending[key] = on)
    return c

func _slider(key: String, lo: float, hi: float, step: float) -> HSlider:
    var s := HSlider.new()
    s.min_value = lo
    s.max_value = hi
    s.step = step
    s.value = pending[key]
    s.custom_minimum_size = Vector2(320, 28)
    s.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    s.value_changed.connect(func(v: float): pending[key] = v)
    return s

func _option(key: String, items: Array) -> OptionButton:
    var o := OptionButton.new()
    for it in items:
        o.add_item(it)
    o.select(int(pending[key]))
    o.item_selected.connect(func(i: int): pending[key] = i)
    return o


# ---------------------------------------------------------------- buttons
func _back() -> void:
    Game.back()

func _apply() -> void:
    Game.settings = pending.duplicate()
    Game.apply_settings()

func _reset() -> void:
    Game.settings = Game.default_settings()
    Game.apply_settings()
    get_tree().reload_current_scene()
