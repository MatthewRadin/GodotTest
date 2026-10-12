extends BaseScreen
## Left: things to buy. Right: upgrade tree. Bottom: current buffs + Buy.

var category := "Floor Plans"
var selected_id := ""
var body: VBoxContainer

func build() -> void:
    body = VBoxContainer.new()
    body.size_flags_vertical = Control.SIZE_EXPAND_FILL
    body.add_theme_constant_override("separation", 12)
    main.add_child(body)
    _refresh()

func _refresh() -> void:
    clear(body)

    # Top: title + category select (top right)
    var top := HBoxContainer.new()
    top.add_theme_constant_override("separation", 8)
    body.add_child(top)
    var title := lbl("Upgrades    (Levels: %d)" % Game.levels, 36, Palette.ACCENT_HOVER)
    title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    top.add_child(title)
    for cat in Game.UPGRADES:
        var b := btn(cat, _pick_category.bind(cat), Vector2(170, 40))
        b.disabled = (cat == category)
        top.add_child(b)

    # Middle: shop list + tree
    var mid := HBoxContainer.new()
    mid.size_flags_vertical = Control.SIZE_EXPAND_FILL
    mid.add_theme_constant_override("separation", 16)
    body.add_child(mid)

    var left := card(mid, Vector2.ZERO, true)
    left.add_child(lbl("For sale: " + category, 24))
    for entry in Game.UPGRADES[category]:
        var up: Dictionary = entry
        var owned: bool = Game.upgrades_owned.has(up["id"])
        var text := "%s%s   (%d lvl)" % ["> " if up["id"] == selected_id else "", up["name"], up["cost"]]
        if owned:
            text = "%s   [owned]" % up["name"]
        var b := btn(text, _select.bind(up["id"]), Vector2(0, 52))
        b.disabled = owned
        left.add_child(b)

    var tree := card(mid, Vector2.ZERO, true)
    tree.add_child(lbl("Upgrade Tree", 24))
    var first := true
    for entry in Game.UPGRADES[category]:
        var up: Dictionary = entry
        if not first:
            tree.add_child(lbl("      |", 18, Palette.MUTED))
        first = false
        var owned: bool = Game.upgrades_owned.has(up["id"])
        tree.add_child(lbl("%s: %s" % [up["name"], up["bonus"]], 20, Palette.GOOD if owned else Palette.TEXT))

    # Bottom: buffs + buy
    var bottom := card(body)
    var buffs: Array[String] = []
    for id in Game.upgrades_owned:
        var up := Game.find_upgrade(id)
        if not up.is_empty():
            buffs.append(str(up["bonus"]))
    bottom.add_child(lbl("Current buffs: " + (", ".join(PackedStringArray(buffs)) if not buffs.is_empty() else "none yet"), 18, Palette.MUTED))
    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 12)
    bottom.add_child(row)
    var buy := btn("Buy Selected", _buy, Vector2(200, 48))
    var sel := Game.find_upgrade(selected_id)
    buy.disabled = sel.is_empty() or Game.upgrades_owned.has(selected_id) or Game.levels < int(sel.get("cost", 999))
    row.add_child(buy)
    row.add_child(btn("Start Next Day", _next_day, Vector2(200, 48)))

func _pick_category(cat: String) -> void:
    category = cat
    selected_id = ""
    _refresh()

func _select(id: String) -> void:
    selected_id = id
    _refresh()

func _buy() -> void:
    var up := Game.find_upgrade(selected_id)
    if up.is_empty() or Game.upgrades_owned.has(selected_id) or Game.levels < int(up["cost"]):
        return
    Game.levels -= int(up["cost"])
    Game.upgrades_owned.append(selected_id)
    selected_id = ""
    _refresh()

func _next_day() -> void:
    Game.next_day()
