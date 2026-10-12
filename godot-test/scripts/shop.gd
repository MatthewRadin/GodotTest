extends BaseScreen
## Top-down shop hub. Move with WASD/arrows, press E near a highlighted spot.

const PLAYER_SPEED := 280.0
const PAUSE_SCENE := preload("res://scenes/pause_menu.tscn")

var player: ColorRect
var customer: ColorRect
var dirt: ColorRect
var hud: Label
var prompt: Label
var spots: Array[Dictionary] = []
var current_spot: Dictionary = {}
var pause_instance: Node
var toast_msg := ""
var toast_left := 0.0

func build() -> void:
    var world := Control.new()
    world.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(world)
    move_child(world, 1)               # above the background, below the HUD

    # Room
    rect(world, Vector2(0, 0), Vector2(1280, 110), Palette.WALL)
    rect(world, Vector2(0, 110), Vector2(1280, 610), Palette.FLOOR)
    for x in range(0, 1280, 160):
        rect(world, Vector2(x, 110), Vector2(3, 610), Color(0.30, 0.22, 0.16))

    # Interactive spots
    _add_spot(world, "Display Case", Rect2(80, 150, 170, 70), Palette.PANEL_LIGHT, _toast.bind("Placeholder: put an owned item in a display case."))
    _add_spot(world, "Display Case", Rect2(300, 150, 170, 70), Palette.PANEL_LIGHT, _toast.bind("Placeholder: put an owned item in a display case."))
    _add_spot(world, "Back Room", Rect2(1110, 130, 130, 150), Palette.PANEL, _go_inventory)
    _add_spot(world, "Repair Bench", Rect2(80, 540, 190, 80), Palette.ACCENT, _go_repair)
    _add_spot(world, "Desk", Rect2(870, 330, 260, 70), Palette.ACCENT, _talk)
    var dirt_spot := _add_spot(world, "Dirt - clean it up", Rect2(520, 440, 100, 60), Color(0.30, 0.23, 0.16), _go_cleaning)
    dirt = dirt_spot

    # Customer + player
    customer = rect(world, Vector2(990, 420), Vector2(28, 40), Palette.MUTED)
    tag(customer, "Customer")
    player = rect(world, Vector2(600, 300), Vector2(28, 40), Palette.ACCENT_HOVER)

    prompt = lbl("", 22, Palette.TEXT, HORIZONTAL_ALIGNMENT_CENTER)
    prompt.position = Vector2(0, 670)
    prompt.size = Vector2(1280, 30)
    world.add_child(prompt)

    # HUD (lives in `main`, which is drawn on top of the world)
    var bar := HBoxContainer.new()
    bar.add_theme_constant_override("separation", 10)
    main.add_child(bar)
    hud = lbl("", 24)
    hud.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    bar.add_child(hud)
    bar.add_child(btn("Inventory (I)", _go_inventory, Vector2(170, 40)))
    bar.add_child(btn("End Day", _end_day, Vector2(120, 40)))
    bar.add_child(btn("Pause (Esc)", _open_pause, Vector2(150, 40)))

    # A customer walks in a few seconds after you arrive
    if not Game.customer_waiting and Game.spawned_today < Game.customers_per_day():
        var t := Timer.new()
        t.wait_time = 3.0
        t.one_shot = true
        t.timeout.connect(Game.spawn_customer)
        add_child(t)
        t.start()

func _add_spot(world: Control, label_text: String, area: Rect2, color: Color, action: Callable) -> ColorRect:
    var r := rect(world, area.position, area.size, color)
    tag(r, label_text)
    spots.append({"area": area, "label": label_text, "action": action, "node": r})
    return r

func _process(delta: float) -> void:
    if get_tree().paused:
        return
    var dir := Vector2.ZERO
    if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
        dir.x -= 1.0
    if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
        dir.x += 1.0
    if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
        dir.y -= 1.0
    if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
        dir.y += 1.0
    player.position = (player.position + dir.normalized() * PLAYER_SPEED * delta).clamp(Vector2(30, 120), Vector2(1220, 650))

    dirt.visible = Game.dirt_present
    customer.visible = Game.customer_waiting
    hud.text = "Day %d     Cash $%d     Customers %d/%d" % [Game.day, Game.cash, Game.spawned_today, Game.customers_per_day()]

    current_spot = {}
    var body := Rect2(player.position, player.size)
    for s in spots:
        var area: Rect2 = s["area"]
        var node: ColorRect = s["node"]
        if node.visible and area.grow(30).intersects(body):
            current_spot = s
            break

    toast_left -= delta
    if toast_left > 0.0:
        prompt.text = toast_msg
    elif not current_spot.is_empty():
        prompt.text = "[E]  " + current_spot["label"]
    else:
        prompt.text = ""

func _unhandled_input(event: InputEvent) -> void:
    var key := event as InputEventKey
    if not key or not key.pressed or key.echo:
        return
    if key.keycode == KEY_E and not current_spot.is_empty():
        var action: Callable = current_spot["action"]
        action.call()
    elif key.keycode == KEY_I:
        _go_inventory()
    elif key.keycode == KEY_ESCAPE:
        _open_pause()

# ---------------------------------------------------------------- actions
func _toast(msg: String) -> void:
    toast_msg = msg
    toast_left = 2.5

func _talk() -> void:
    if Game.customer_waiting:
        Game.goto_from("negotiations", "shop")
    else:
        _toast("No customer at the desk yet.")

func _go_cleaning() -> void:
    Game.goto_from("cleaning", "shop")

func _go_inventory() -> void:
    Game.goto_from("inventory", "shop")

func _go_repair() -> void:
    Game.goto("repair")

func _end_day() -> void:
    Game.goto("end_of_day")

func _open_pause() -> void:
    if is_instance_valid(pause_instance):
        return
    pause_instance = PAUSE_SCENE.instantiate()
    add_child(pause_instance)
    get_tree().paused = true
