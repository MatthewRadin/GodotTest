extends BaseScreen

var detail: VBoxContainer

func build() -> void:
    top_bar("Inventory", "< Back (Esc)", Game.back)
    if Game.inventory.is_empty():
        main.add_child(lbl("Your inventory is empty. Buy something at the desk!", 22, Palette.MUTED))
        return

    var row := HBoxContainer.new()
    row.size_flags_vertical = Control.SIZE_EXPAND_FILL
    row.add_theme_constant_override("separation", 16)
    main.add_child(row)

    var scroll := ScrollContainer.new()
    scroll.custom_minimum_size = Vector2(420, 0)
    row.add_child(scroll)
    var list := VBoxContainer.new()
    list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    list.add_theme_constant_override("separation", 8)
    scroll.add_child(list)
    for item in Game.inventory:
        var it: Dictionary = item
        list.add_child(btn("%s   ($%d)" % [it["name"], Game.item_value(it)], _select.bind(it), Vector2(0, 56)))

    detail = card(row, Vector2.ZERO, true)
    _select(Game.inventory[0])

func _unhandled_input(event: InputEvent) -> void:
    var key := event as InputEventKey
    if key and key.pressed and not key.echo and key.keycode == KEY_ESCAPE:
        Game.back()

func _select(item: Dictionary) -> void:
    Game.current_item = item
    clear(detail)
    var pic := ColorRect.new()
    pic.color = Palette.PANEL_LIGHT
    pic.custom_minimum_size = Vector2(0, 160)
    tag(pic, "[ item image placeholder ]")
    detail.add_child(pic)
    detail.add_child(lbl(str(item["name"]), 32, Palette.ACCENT_HOVER))
    detail.add_child(lbl(str(item["desc"]), 18, Palette.MUTED))
    detail.add_child(lbl("Defects: " + ", ".join(PackedStringArray(item["defects"])), 20))
    detail.add_child(lbl("Current worth: $%d" % Game.item_value(item), 22))
    detail.add_child(lbl("Worth when cleaned up: $%d" % Game.cleaned_value(item), 22, Palette.GOOD))
    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 12)
    detail.add_child(row)
    row.add_child(btn("Inspect", _inspect, Vector2(160, 44)))
    row.add_child(btn("Repair", _repair, Vector2(160, 44)))

func _inspect() -> void:
    Game.goto_from("inspection", "inventory")

func _repair() -> void:
    Game.goto("repair")
