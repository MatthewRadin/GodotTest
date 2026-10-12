@tool
class_name Hotspot
extends ColorRect
## A spot in the shop the player can interact with. Move/resize it in the
## editor and change these properties in the Inspector.

@export var label_text := "Spot":
    set(v):
        label_text = v
        if is_node_ready():
            $Tag.text = v
@export_enum("talk", "inventory", "repair", "cleaning", "toast") var action := "toast"
@export var toast_text := "Placeholder."
@export var is_dirt := false       # hidden automatically once the dirt is cleaned

func _ready() -> void:
    $Tag.text = label_text
