extends BaseScreen
## Hold the left mouse button and scrub the sponge over the dirt.

var cells: Array[ColorRect] = []
var remaining := 0
var sponge: ColorRect
var status: Label

func build() -> void:
    top_bar("Cleaning", "< Back to Shop", Game.go_shop)
    main.add_child(lbl("Hold the left mouse button and scrub the dirt away.", 18, Palette.MUTED))
    var area := Control.new()
    area.custom_minimum_size = Vector2(800, 400)
    area.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    main.add_child(area)
    rect(area, Vector2.ZERO, Vector2(800, 400), Palette.FLOOR)
    for y in 5:
        for x in 8:
            cells.append(rect(area, Vector2(x * 100, y * 80), Vector2(100, 80), Color(0.28, 0.20, 0.13, randf_range(0.65, 0.95))))
    remaining = cells.size()
    status = lbl("", 24, Palette.GOOD, HORIZONTAL_ALIGNMENT_CENTER)
    main.add_child(status)

    sponge = rect(self, Vector2.ZERO, Vector2(60, 36), Palette.MUTED)   # drawn above everything
    tag(sponge, "sponge")

func _process(_delta: float) -> void:
    var m := get_global_mouse_position()
    sponge.global_position = m - sponge.size / 2.0
    if remaining > 0 and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        for c in cells:
            if c.visible and c.get_global_rect().grow(-10).has_point(m):
                c.visible = false
                remaining -= 1
        if remaining == 0:
            Game.dirt_present = false
            status.text = "All clean! (placeholder reward text)"
