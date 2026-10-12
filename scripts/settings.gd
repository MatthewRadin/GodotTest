extends Control
## Controls are nodes in settings.tscn. Values are read when Apply is pressed.

@onready var fullscreen: CheckBox = %Fullscreen
@onready var resolution: OptionButton = %Resolution
@onready var brightness: HSlider = %Brightness
@onready var ui_scale: HSlider = %UiScale
@onready var graphics: OptionButton = %Graphics
@onready var master: HSlider = %Master
@onready var music: HSlider = %Music
@onready var sfx: HSlider = %Sfx
@onready var output_device: OptionButton = %OutputDevice
@onready var mute_unfocused: CheckBox = %MuteUnfocused
@onready var input_device: OptionButton = %InputDevice

var devices: PackedStringArray

func _ready() -> void:
    devices = AudioServer.get_output_device_list()
    for d in devices:
        output_device.add_item(d)
    var s: Dictionary = Game.settings
    fullscreen.button_pressed = s["fullscreen"]
    resolution.select(int(s["resolution"]))
    brightness.value = s["brightness"]
    ui_scale.value = s["ui_scale"]
    graphics.select(int(s["graphics"]))
    master.value = s["master"]
    music.value = s["music"]
    sfx.value = s["sfx"]
    output_device.select(maxi(devices.find(s["audio_device"]), 0))
    mute_unfocused.button_pressed = s["mute_unfocused"]
    input_device.select(int(s["input_device"]))

func _on_apply_pressed() -> void:
    var s: Dictionary = Game.settings
    s["fullscreen"] = fullscreen.button_pressed
    s["resolution"] = resolution.selected
    s["brightness"] = brightness.value
    s["ui_scale"] = ui_scale.value
    s["graphics"] = graphics.selected
    s["master"] = master.value
    s["music"] = music.value
    s["sfx"] = sfx.value
    if output_device.selected >= 0:
        s["audio_device"] = devices[output_device.selected]
    s["mute_unfocused"] = mute_unfocused.button_pressed
    s["input_device"] = input_device.selected
    Game.apply_settings()

func _on_reset_pressed() -> void:
    Game.settings = Game.default_settings()
    Game.apply_settings()
    get_tree().reload_current_scene()

func _on_back_pressed() -> void:
    Game.back()
