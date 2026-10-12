extends Control

@onready var continue_button: Button = %ContinueButton

func _ready() -> void:
    continue_button.disabled = not Game.has_save()

func _on_new_run_pressed() -> void:
    Game.new_run()
    Game.goto("shop")

func _on_continue_pressed() -> void:
    if Game.load_game():
        Game.goto("shop")

func _on_settings_pressed() -> void:
    Game.goto_from("settings", "main_menu")

func _on_quit_pressed() -> void:
    get_tree().quit()
