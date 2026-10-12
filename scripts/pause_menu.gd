extends Control
## Instanced on top of the shop when Esc is pressed. process_mode is "Always"
## (set in the scene) so it keeps working while the tree is paused.

@onready var status: Label = %StatusLabel
var opened_at := 0

func _ready() -> void:
    opened_at = Time.get_ticks_msec()

func _unhandled_input(event: InputEvent) -> void:
    var key := event as InputEventKey
    if key and key.pressed and not key.echo and key.keycode == KEY_ESCAPE:
        if Time.get_ticks_msec() - opened_at > 200:   # ignore the Esc press that opened us
            _on_resume_pressed()

func _on_resume_pressed() -> void:
    get_tree().paused = false
    queue_free()

func _on_save_pressed() -> void:
    Game.save_game()
    status.text = "Saved."

func _on_load_pressed() -> void:
    if Game.load_game():
        Game.goto("shop")
    else:
        status.text = "No save file found."

func _on_settings_pressed() -> void:
    Game.goto_from("settings", "shop")

func _on_quit_pressed() -> void:
    Game.goto("main_menu")
