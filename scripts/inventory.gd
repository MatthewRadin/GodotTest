extends Control
## The layout is nodes; only the list of item buttons is filled in from code.

@onready var row: Control = %Row
@onready var empty_label: Label = %EmptyLabel
@onready var item_list: VBoxContainer = %ItemList
@onready var name_label: Label = %NameLabel
@onready var desc_label: Label = %DescLabel
@onready var defects_label: Label = %DefectsLabel
@onready var worth_label: Label = %WorthLabel
@onready var cleaned_label: Label = %CleanedLabel

func _ready() -> void:
    var has_items := not Game.inventory.is_empty()
    row.visible = has_items
    empty_label.visible = not has_items
    if not has_items:
        return
    for entry in Game.inventory:
        var it: Dictionary = entry
        var b := Button.new()
        b.text = "%s   ($%d)" % [it["name"], Game.item_value(it)]
        b.custom_minimum_size = Vector2(0, 56)
        b.pressed.connect(_select.bind(it))
        item_list.add_child(b)
    _select(Game.inventory[0])

func _unhandled_input(event: InputEvent) -> void:
    var key := event as InputEventKey
    if key and key.pressed and not key.echo and key.keycode == KEY_ESCAPE:
        Game.back()

func _select(item: Dictionary) -> void:
    Game.current_item = item
    name_label.text = str(item["name"])
    desc_label.text = str(item["desc"])
    defects_label.text = "Defects: " + ", ".join(PackedStringArray(item["defects"]))
    worth_label.text = "Current worth: $%d" % Game.item_value(item)
    cleaned_label.text = "Worth when cleaned up: $%d" % Game.cleaned_value(item)

func _on_inspect_button_pressed() -> void:
    Game.goto_from("inspection", "inventory")

func _on_repair_button_pressed() -> void:
    Game.goto("repair")

func _on_back_button_pressed() -> void:
    Game.back()
