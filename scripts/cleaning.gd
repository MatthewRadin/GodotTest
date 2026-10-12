extends Control
## Hold the left mouse button and scrub. The dirt tiles are ColorRect nodes in
## the Grid; "cleaned" just means their alpha is 0 (hiding them would reflow the grid).

@onready var cells: Array[Node] = %Grid.get_children()
@onready var sponge: Control = %Sponge
@onready var status: Label = %StatusLabel

var remaining := 0

func _ready() -> void:
    remaining = cells.size()
    if not Game.dirt_present:
        for c in cells:
            (c as ColorRect).color.a = 0.0
        remaining = 0
        status.text = "Already spotless!"

func _process(_delta: float) -> void:
    var m := get_global_mouse_position()
    sponge.global_position = m - sponge.size / 2.0
    if remaining > 0 and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        for c in cells:
            var cell := c as ColorRect
            if cell.color.a > 0.0 and cell.get_global_rect().grow(-10).has_point(m):
                cell.color.a = 0.0
                remaining -= 1
        if remaining == 0:
            Game.dirt_present = false
            status.text = "All clean! (placeholder reward text)"

func _on_back_button_pressed() -> void:
    Game.go_shop()
