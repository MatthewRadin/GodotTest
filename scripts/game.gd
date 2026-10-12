extends Node
## Autoload singleton registered as "Game" in project.godot.
## Holds run state, scene switching, saving and settings.

const SAVE_PATH := "user://pawn_save.json"
const BASE_CUSTOMERS_PER_DAY := 4

const SCENES := {
    "main_menu": "res://scenes/main_menu.tscn",
    "settings": "res://scenes/settings.tscn",
    "shop": "res://scenes/shop.tscn",
    "cleaning": "res://scenes/cleaning.tscn",
    "negotiations": "res://scenes/negotiations.tscn",
    "inspection": "res://scenes/inspection.tscn",
    "inventory": "res://scenes/inventory.tscn",
    "repair": "res://scenes/repair.tscn",
    "upgrades": "res://scenes/upgrades.tscn",
    "end_of_day": "res://scenes/end_of_day.tscn",
}

const RESOLUTIONS := [Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080)]

# Placeholder items. Edit / add as many as you like.
const ITEM_POOL := [
    {"name": "Antique Pocket Watch", "base": 120, "desc": "Placeholder: a tarnished brass pocket watch."},
    {"name": "Brass Trumpet", "base": 180, "desc": "Placeholder: a dented but charming trumpet."},
    {"name": "Vinyl Record Box", "base": 90, "desc": "Placeholder: a crate of dusty records."},
    {"name": "Old Film Camera", "base": 150, "desc": "Placeholder: a camera that may still work."},
    {"name": "Porcelain Vase", "base": 200, "desc": "Placeholder: a fragile painted vase."},
    {"name": "Leather Journal", "base": 60, "desc": "Placeholder: a worn leather journal."},
    {"name": "Wool Overcoat", "base": 80, "desc": "Placeholder: a heavy coat with moth holes."},
]
const DEFECTS := ["Cracked", "Scratched", "Missing a piece", "Rusty", "Faded", "Loose hinge"]

# Upgrade tree placeholders. "key" is what the bonus affects (see bonus()).
const UPGRADES := {
    "Floor Plans": [
        {"id": "floor_1", "name": "Bigger Floor", "cost": 2, "bonus": "+1 customer per day", "key": "customers", "amount": 1},
        {"id": "floor_2", "name": "Back Annex", "cost": 4, "bonus": "+2 customers per day", "key": "customers", "amount": 2},
    ],
    "Item Display": [
        {"id": "display_1", "name": "Glass Cases", "cost": 2, "bonus": "+10% sale prices", "key": "sale_bonus", "amount": 10},
        {"id": "display_2", "name": "Spotlights", "cost": 3, "bonus": "+10% sale prices", "key": "sale_bonus", "amount": 10},
    ],
    "Shop Decor": [
        {"id": "decor_1", "name": "Warm Rug", "cost": 1, "bonus": "Placeholder bonus", "key": "decor", "amount": 1},
        {"id": "decor_2", "name": "Wall Clock", "cost": 2, "bonus": "Placeholder bonus", "key": "decor", "amount": 1},
    ],
    "Tools & Automation": [
        {"id": "tool_1", "name": "Better Hammer", "cost": 2, "bonus": "+1 repair quality per use", "key": "repair", "amount": 1},
        {"id": "tool_2", "name": "Power Sander", "cost": 3, "bonus": "+2 repair quality per use", "key": "repair", "amount": 2},
    ],
}

var return_to := "shop"          # where Back buttons (settings, inspection, inventory) go

var cash := 100
var day := 1
var levels := 0
var inventory: Array = []
var upgrades_owned: Array = []
var stats := {"bought": 0, "sold": 0, "sellers": 0, "buyers": 0}
var spawned_today := 0
var dirt_present := true
var day_scored := false
var earned_today := 0

# The customer currently at the desk
var customer_waiting := false
var current_item: Dictionary = {}
var current_mode := "sell"       # "sell" = customer sells to you, "buy" = customer buys from you
var current_price := 0
var customer_limit := 0          # the customer's secret walk-away price

var settings: Dictionary = {}
var _dimmer: ColorRect


func _ready() -> void:
    settings = default_settings()
    # Full-screen black overlay used for the brightness setting
    var layer := CanvasLayer.new()
    layer.layer = 100
    add_child(layer)
    _dimmer = ColorRect.new()
    _dimmer.color = Color(0, 0, 0, 0)
    _dimmer.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layer.add_child(_dimmer)
    _dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    new_run()


func _notification(what: int) -> void:
    if what == NOTIFICATION_APPLICATION_FOCUS_OUT and settings.get("mute_unfocused", false):
        AudioServer.set_bus_mute(0, true)
    elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
        AudioServer.set_bus_mute(0, false)


# ---------------------------------------------------------------- scenes
func goto(scene_key: String) -> void:
    get_tree().paused = false
    get_tree().change_scene_to_file(SCENES[scene_key])

func goto_from(scene_key: String, back_to: String) -> void:
    return_to = back_to
    goto(scene_key)

func back() -> void:
    goto(return_to)

func go_shop() -> void:
    goto("shop")


# ---------------------------------------------------------------- run state
func new_run() -> void:
    cash = 100
    day = 1
    levels = 0
    upgrades_owned = []
    inventory = [make_item(), make_item()]   # a couple of starter items so the demo has something to show
    _reset_day()

func _reset_day() -> void:
    stats = {"bought": 0, "sold": 0, "sellers": 0, "buyers": 0}
    spawned_today = 0
    dirt_present = true
    day_scored = false
    earned_today = 0
    customer_waiting = false
    current_item = {}

func next_day() -> void:
    day += 1
    _reset_day()
    goto("shop")

func customers_per_day() -> int:
    return BASE_CUSTOMERS_PER_DAY + bonus("customers")

func score_day() -> int:
    if not day_scored:
        day_scored = true
        var profit := maxf(0.0, float(stats["sold"]) - float(stats["bought"]))
        earned_today = 1 + int(profit / 40.0) + int(float(stats["sellers"]) + float(stats["buyers"])) / 3
        levels += earned_today
    return earned_today


# ---------------------------------------------------------------- items
func make_item() -> Dictionary:
    var template: Dictionary = ITEM_POOL.pick_random()
    var item := template.duplicate()
    item["quality"] = randi_range(25, 85)
    item["defects"] = [DEFECTS.pick_random()]
    item["appraised"] = false
    return item

func item_value(item: Dictionary) -> int:
    return int(float(item["base"]) * (0.4 + 0.8 * float(item["quality"]) / 100.0))

func cleaned_value(item: Dictionary) -> int:
    var q := minf(100.0, float(item["quality"]) + 20.0)
    return int(float(item["base"]) * (0.4 + 0.8 * q / 100.0))

func condition_name(quality: float) -> String:
    if quality >= 75.0:
        return "Good"
    if quality >= 50.0:
        return "Fair"
    if quality >= 30.0:
        return "Poor"
    return "Rough"


# ---------------------------------------------------------------- customers & deals
func spawn_customer() -> void:
    customer_waiting = true
    spawned_today += 1
    if randf() < 0.4 and not inventory.is_empty():
        current_mode = "buy"
        current_item = inventory.pick_random()
        var v := item_value(current_item)
        customer_limit = int(v * randf_range(1.05, 1.35))
        current_price = int(v * randf_range(0.5, 0.8))
    else:
        current_mode = "sell"
        current_item = make_item()
        var v2 := item_value(current_item)
        customer_limit = int(v2 * randf_range(0.6, 0.9))
        current_price = int(v2 * randf_range(1.2, 1.6))

## Returns {"accepted": bool, "counter": int}
func evaluate_offer(offer: int) -> Dictionary:
    var mid := int((offer + current_price) / 2.0)
    if current_mode == "sell":
        if offer >= customer_limit:
            return {"accepted": true, "counter": offer}
        return {"accepted": false, "counter": clampi(mid, customer_limit, current_price)}
    if offer <= customer_limit:
        return {"accepted": true, "counter": offer}
    return {"accepted": false, "counter": clampi(mid, current_price, customer_limit)}

## Returns "ok" or "no_cash"
func finish_deal(accept: bool) -> String:
    if accept:
        if current_mode == "sell":
            if cash < current_price:
                return "no_cash"
            cash -= current_price
            inventory.append(current_item)
            stats["bought"] = int(stats["bought"]) + current_price
        else:
            var gain := int(current_price * (1.0 + bonus("sale_bonus") / 100.0))
            cash += gain
            inventory.erase(current_item)
            stats["sold"] = int(stats["sold"]) + gain
    if current_mode == "sell":
        stats["sellers"] = int(stats["sellers"]) + 1
    else:
        stats["buyers"] = int(stats["buyers"]) + 1
    customer_waiting = false
    current_item = {}
    return "ok"


# ---------------------------------------------------------------- upgrades
func find_upgrade(id: String) -> Dictionary:
    for category in UPGRADES:
        for up in UPGRADES[category]:
            if up["id"] == id:
                return up
    return {}

func bonus(key: String) -> int:
    var total := 0
    for id in upgrades_owned:
        var up := find_upgrade(id)
        if not up.is_empty() and up["key"] == key:
            total += int(up["amount"])
    return total


# ---------------------------------------------------------------- save / load
func save_game() -> void:
    var data := {
        "cash": cash, "day": day, "levels": levels, "inventory": inventory,
        "upgrades": upgrades_owned, "dirt": dirt_present, "stats": stats,
        "spawned": spawned_today,
    }
    var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if f:
        f.store_string(JSON.stringify(data))

func has_save() -> bool:
    return FileAccess.file_exists(SAVE_PATH)

func load_game() -> bool:
    if not has_save():
        return false
    var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
    var data = JSON.parse_string(f.get_as_text())
    if typeof(data) != TYPE_DICTIONARY:
        return false
    cash = int(data.get("cash", 100))
    day = int(data.get("day", 1))
    levels = int(data.get("levels", 0))
    inventory = data.get("inventory", [])
    upgrades_owned = data.get("upgrades", [])
    dirt_present = bool(data.get("dirt", true))
    stats = data.get("stats", stats)
    spawned_today = int(data.get("spawned", 0))
    customer_waiting = false
    current_item = {}
    return true


# ---------------------------------------------------------------- settings
func default_settings() -> Dictionary:
    return {
        "fullscreen": false, "resolution": 0, "brightness": 1.0, "ui_scale": 1.0,
        "graphics": 2, "master": 0.8, "music": 0.7, "sfx": 0.8,
        "audio_device": "Default", "mute_unfocused": true, "input_device": 0,
    }

func apply_settings() -> void:
    if settings["fullscreen"]:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
    else:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
        DisplayServer.window_set_size(RESOLUTIONS[int(settings["resolution"])])
    get_window().content_scale_factor = float(settings["ui_scale"])
    _dimmer.color.a = clampf(1.0 - float(settings["brightness"]), 0.0, 0.6)
    AudioServer.set_bus_volume_db(0, linear_to_db(maxf(float(settings["master"]), 0.0001)))
    AudioServer.output_device = settings["audio_device"]
    # music / sfx volumes are stored here; hook them to buses once you have audio.
