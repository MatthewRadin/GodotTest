extends Control
## Top-down shop hub. Move with WASD/arrows, press E near a Hotspot.
## Hotspots are nodes under "World/Spots" - add, move or resize them in the editor.

const PLAYER_SPEED := 280.0
const PAUSE_SCENE := preload("res://scenes/pause_menu.tscn")

@onready var player: ColorRect = %Player
@onready var customer: ColorRect = %Customer
@onready var spots: Node = %Spots
@onready var hud: Label = %HudLabel
@onready var prompt: Label = %Prompt
@onready var customer_timer: Timer = %CustomerTimer

var current_spot: Hotspot = null
var pause_instance: Node
var toast_msg := ""
var toast_left := 0.0

func _ready() -> void:
	if not Game.customer_waiting and Game.spawned_today < Game.customers_per_day():
		customer_timer.start()

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

	customer.visible = Game.customer_waiting
	hud.text = "Day %d     Cash $%d     Customers %d/%d" % [Game.day, Game.cash, Game.spawned_today, Game.customers_per_day()]

	current_spot = null
	var body := Rect2(player.global_position, player.size)
	for child in spots.get_children():
		var h := child as Hotspot
		if h == null:
			continue
		if h.is_dirt:
			h.visible = Game.dirt_present
		if h.visible and Rect2(h.global_position, h.size).grow(30).intersects(body):
			current_spot = h
			break

	toast_left -= delta
	if toast_left > 0.0:
		prompt.text = toast_msg
	elif current_spot != null:
		prompt.text = "[E]  " + current_spot.label_text
	else:
		prompt.text = ""

func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if not key or not key.pressed or key.echo:
		return
	if key.keycode == KEY_E and current_spot != null:
		_interact(current_spot)
	elif key.keycode == KEY_I:
		_on_inventory_button_pressed()
	elif key.keycode == KEY_ESCAPE:
		_on_pause_button_pressed()

func _interact(h: Hotspot) -> void:
	match h.action:
		"talk":
			if Game.customer_waiting:
				Game.goto_from("negotiations", "shop")
			else:
				_toast("No customer at the desk yet.")
		"inventory":
			Game.goto_from("inventory", "shop")
		"repair":
			Game.goto("repair")
		"cleaning":
			Game.goto_from("cleaning", "shop")
		_:
			_toast(h.toast_text)

func _toast(msg: String) -> void:
	toast_msg = msg
	toast_left = 2.5

func _on_customer_timer_timeout() -> void:
	Game.spawn_customer()

func _on_inventory_button_pressed() -> void:
	Game.goto_from("inventory", "shop")

func _on_end_day_button_pressed() -> void:
	Game.goto("end_of_day")

func _on_pause_button_pressed() -> void:
	if is_instance_valid(pause_instance):
		return
	pause_instance = PAUSE_SCENE.instantiate()
	add_child(pause_instance)
	get_tree().paused = true
