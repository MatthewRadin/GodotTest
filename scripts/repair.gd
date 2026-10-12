extends Control
## Tool buttons are nodes in the "Tools" grid; the button's text is the tool name
## and must match a key in TOOLS. Add a Button + a TOOLS entry for a new tool.

# tool name -> (min, max) quality change per use. Negative = you made it worse.
const TOOLS := {
    "Hammer": Vector2i(-4, 7),
    "Screwdriver": Vector2i(-2, 5),
    "Magnifying Glass": Vector2i(0, 2),
    "Scissors": Vector2i(-3, 5),
    "Sander": Vector2i(-5, 9),
    "Glue": Vector2i(-1, 4),
}

@onready var row: Control = %Row
@onready var empty_label: Label = %EmptyLabel
@onready var tools: Node = %Tools
@onready var info_label: Label = %InfoLabel
@onready var quality_bar: ProgressBar = %QualityBar
@onready var log_label: Label = %LogLabel
@onready var price_label: Label = %PriceLabel

var item: Dictionary = {}

func _ready() -> void:
    var has_items := not Game.inventory.is_empty()
    row.visible = has_items
    empty_label.visible = not has_items
    if not has_items:
        return
    item = Game.current_item if Game.inventory.has(Game.current_item) else Game.inventory[0]
    for b in tools.get_children():
        (b as Button).pressed.connect(_use_tool.bind((b as Button).text))
    _refresh()

func _refresh() -> void:
    var q := int(item["quality"])
    var v := Game.item_value(item)
    info_label.text = "%s\nCondition: %s" % [item["name"], Game.condition_name(q)]
    quality_bar.value = q
    price_label.text = "Similar condition:\n   $%d - $%d\n\nAll similar items (any condition):\n   $%d - $%d" % [
        int(v * 0.9), int(v * 1.1), int(item["base"] * 0.4), int(item["base"] * 1.2)]

func _use_tool(tool_name: String) -> void:
    var r: Vector2i = TOOLS[tool_name]
    var change := randi_range(r.x, r.y)
    if change > 0:
        change += Game.bonus("repair")
    item["quality"] = clampi(int(item["quality"]) + change, 0, 100)
    log_label.text = "You used the %s: quality %+d" % [tool_name, change]
    _refresh()

func _on_next_button_pressed() -> void:
    var i := Game.inventory.find(item)
    item = Game.inventory[(i + 1) % Game.inventory.size()]
    Game.current_item = item
    log_label.text = "Switched item."
    _refresh()

func _on_back_button_pressed() -> void:
    Game.go_shop()
