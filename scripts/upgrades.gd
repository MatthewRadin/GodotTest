extends Control
## Category buttons, panels and the Buy / Next Day buttons are nodes.
## The two lists (things for sale, upgrade tree) are filled from Game.UPGRADES.
## Category button text must match a key in Game.UPGRADES.

@onready var title: Label = %TitleLabel
@onready var categories: Node = %Categories
@onready var list_title: Label = %ListTitle
@onready var items: VBoxContainer = %Items
@onready var tree: VBoxContainer = %Tree
@onready var buffs_label: Label = %BuffsLabel
@onready var buy_button: Button = %BuyButton

var category := "Floor Plans"
var selected_id := ""

func _ready() -> void:
    for b in categories.get_children():
        (b as Button).pressed.connect(_pick_category.bind((b as Button).text))
    _refresh()

func _clear(node: Node) -> void:
    for c in node.get_children():
        node.remove_child(c)
        c.queue_free()

func _refresh() -> void:
    title.text = "Upgrades    (Levels: %d)" % Game.levels
    for b in categories.get_children():
        (b as Button).disabled = ((b as Button).text == category)
    list_title.text = "For sale: " + category
    _clear(items)
    _clear(tree)

    var first := true
    for entry in Game.UPGRADES[category]:
        var up: Dictionary = entry
        var owned: bool = Game.upgrades_owned.has(up["id"])

        var text := "%s%s   (%d lvl)" % ["> " if up["id"] == selected_id else "", up["name"], up["cost"]]
        if owned:
            text = "%s   [owned]" % up["name"]
        var b := Button.new()
        b.text = text
        b.custom_minimum_size = Vector2(0, 52)
        b.disabled = owned
        b.pressed.connect(_select.bind(up["id"]))
        items.add_child(b)

        if not first:
            var link := Label.new()
            link.text = "      |"
            tree.add_child(link)
        first = false
        var l := Label.new()
        l.text = "%s: %s" % [up["name"], up["bonus"]]
        l.add_theme_color_override("font_color", Palette.GOOD if owned else Palette.TEXT)
        tree.add_child(l)

    var buffs: Array[String] = []
    for id in Game.upgrades_owned:
        var up := Game.find_upgrade(id)
        if not up.is_empty():
            buffs.append(str(up["bonus"]))
    buffs_label.text = "Current buffs: " + (", ".join(PackedStringArray(buffs)) if not buffs.is_empty() else "none yet")

    var sel := Game.find_upgrade(selected_id)
    buy_button.disabled = sel.is_empty() or Game.upgrades_owned.has(selected_id) or Game.levels < int(sel.get("cost", 999))

func _pick_category(cat: String) -> void:
    category = cat
    selected_id = ""
    _refresh()

func _select(id: String) -> void:
    selected_id = id
    _refresh()

func _on_buy_button_pressed() -> void:
    var up := Game.find_upgrade(selected_id)
    if up.is_empty() or Game.upgrades_owned.has(selected_id) or Game.levels < int(up["cost"]):
        return
    Game.levels -= int(up["cost"])
    Game.upgrades_owned.append(selected_id)
    selected_id = ""
    _refresh()

func _on_next_day_button_pressed() -> void:
    Game.next_day()
