extends BaseScreen

const EXPERT_COST := 20

var item: Dictionary
var value_lbl: Label
var expert_btn: Button

func build() -> void:
    top_bar("Item Inspection", "< Back", Game.back)
    item = Game.current_item
    if item.is_empty():
        main.add_child(lbl("Nothing to inspect.", 24, Palette.MUTED))
        return

    var row := HBoxContainer.new()
    row.size_flags_vertical = Control.SIZE_EXPAND_FILL
    row.add_theme_constant_override("separation", 16)
    main.add_child(row)

    var left := card(row, Vector2(340, 0))
    var pic := ColorRect.new()
    pic.color = Palette.PANEL_LIGHT
    pic.custom_minimum_size = Vector2(300, 300)
    tag(pic, "[ item image placeholder ]")
    left.add_child(pic)

    var right := card(row, Vector2.ZERO, true)
    right.add_child(lbl(str(item["name"]), 36, Palette.ACCENT_HOVER))
    right.add_child(lbl(str(item["desc"]), 18, Palette.MUTED))
    var q := float(item["quality"])
    right.add_child(lbl("Condition: %s  (%d / 100)" % [Game.condition_name(q), int(q)], 22))
    right.add_child(lbl("Damage: " + ", ".join(PackedStringArray(item["defects"])), 22))
    value_lbl = lbl("", 26, Palette.GOOD)
    right.add_child(value_lbl)
    expert_btn = btn("Call an Expert ($%d)" % EXPERT_COST, _call_expert, Vector2(280, 48))
    right.add_child(expert_btn)
    _refresh()

func _refresh() -> void:
    var v := Game.item_value(item)
    if item.get("appraised", false):
        value_lbl.text = "Expert appraisal: $%d" % v
        expert_btn.disabled = true
    else:
        value_lbl.text = "Estimated value: $%d - $%d" % [int(v * 0.7), int(v * 1.3)]

func _call_expert() -> void:
    if Game.cash < EXPERT_COST:
        value_lbl.text = "Not enough cash for an expert."
        return
    Game.cash -= EXPERT_COST
    item["appraised"] = true
    _refresh()
