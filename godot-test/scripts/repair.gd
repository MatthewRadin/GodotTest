extends BaseScreen

# tool name -> (min, max) quality change per use. Negative = you made it worse.
const TOOLS := {
    "Hammer": Vector2i(-4, 7),
    "Screwdriver": Vector2i(-2, 5),
    "Magnifying Glass": Vector2i(0, 2),
    "Scissors": Vector2i(-3, 5),
    "Sander": Vector2i(-5, 9),
    "Glue": Vector2i(-1, 4),
}

var item: Dictionary = {}
var bar: ProgressBar
var info: Label
var price_info: Label
var log_lbl: Label

func build() -> void:
    top_bar("Repair Bench", "< Return to Shop", Game.go_shop)
    if Game.inventory.is_empty():
        main.add_child(lbl("Your inventory is empty. Buy something first!", 22, Palette.MUTED))
        return
    item = Game.current_item if Game.inventory.has(Game.current_item) else Game.inventory[0]

    var row := HBoxContainer.new()
    row.size_flags_vertical = Control.SIZE_EXPAND_FILL
    row.add_theme_constant_override("separation", 16)
    main.add_child(row)

    # Left: the item
    var left := card(row, Vector2(320, 0))
    var pic := ColorRect.new()
    pic.color = Palette.PANEL_LIGHT
    pic.custom_minimum_size = Vector2(0, 200)
    tag(pic, "[ item image placeholder ]")
    left.add_child(pic)
    info = lbl("", 22)
    left.add_child(info)
    left.add_child(lbl("Item quality", 16, Palette.MUTED))
    bar = ProgressBar.new()
    bar.custom_minimum_size = Vector2(0, 28)
    left.add_child(bar)
    left.add_child(btn("Next Item", _next_item, Vector2(0, 40)))

    # Middle: tools
    var mid := card(row, Vector2(340, 0))
    mid.add_child(lbl("Tools", 24, Palette.ACCENT_HOVER))
    var grid := GridContainer.new()
    grid.columns = 2
    grid.add_theme_constant_override("h_separation", 10)
    grid.add_theme_constant_override("v_separation", 10)
    mid.add_child(grid)
    for tool_name in TOOLS:
        grid.add_child(btn(tool_name, _use_tool.bind(tool_name), Vector2(150, 56)))
    log_lbl = lbl("Pick a tool to start repairing.", 18, Palette.MUTED)
    mid.add_child(log_lbl)

    # Right: pricing computer
    var right := card(row, Vector2.ZERO, true)
    right.add_child(lbl("Price Computer", 24, Palette.ACCENT_HOVER))
    price_info = lbl("", 20)
    right.add_child(price_info)
    _refresh()

func _refresh() -> void:
    var q := int(item["quality"])
    var v := Game.item_value(item)
    info.text = "%s\nCondition: %s" % [item["name"], Game.condition_name(q)]
    bar.value = q
    price_info.text = "Similar condition:\n   $%d - $%d\n\nAll similar items (any condition):\n   $%d - $%d" % [
        int(v * 0.9), int(v * 1.1), int(item["base"] * 0.4), int(item["base"] * 1.2)]

func _use_tool(tool_name: String) -> void:
    var r: Vector2i = TOOLS[tool_name]
    var change := randi_range(r.x, r.y)
    if change > 0:
        change += Game.bonus("repair")
    item["quality"] = clampi(int(item["quality"]) + change, 0, 100)
    log_lbl.text = "You used the %s: quality %+d" % [tool_name, change]
    _refresh()

func _next_item() -> void:
    var i := Game.inventory.find(item)
    item = Game.inventory[(i + 1) % Game.inventory.size()]
    Game.current_item = item
    log_lbl.text = "Switched item."
    _refresh()
