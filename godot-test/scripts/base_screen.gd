class_name BaseScreen
extends Control
## Base class for every screen. Paints the brown background, applies the theme,
## creates a padded `main` column and offers small UI helpers so each screen
## script only has to override build().

var bg_color: Color = Palette.BG
var main: VBoxContainer

func _ready() -> void:
    theme = Game.theme
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var bg := ColorRect.new()
    bg.color = bg_color
    add_child(bg)                      # STOP mouse filter (default) so overlays block clicks
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var margin := MarginContainer.new()
    for side in ["left", "right", "top", "bottom"]:
        margin.add_theme_constant_override("margin_" + side, 24)
    add_child(margin)
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    main = VBoxContainer.new()
    main.add_theme_constant_override("separation", 12)
    margin.add_child(main)
    build()

func build() -> void:
    pass   # override in subclasses


# ---------------------------------------------------------------- helpers
func lbl(text: String, font_size: int = 20, color: Color = Color.TRANSPARENT, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
    var l := Label.new()
    l.text = text
    l.horizontal_alignment = align
    l.add_theme_font_size_override("font_size", font_size)
    if color.a > 0.0:
        l.add_theme_color_override("font_color", color)
    return l

func btn(text: String, cb: Callable, min_size: Vector2 = Vector2(0, 44)) -> Button:
    var b := Button.new()
    b.text = text
    b.custom_minimum_size = min_size
    b.pressed.connect(cb)
    return b

func spacer(h: float = 12.0) -> Control:
    var c := Control.new()
    c.custom_minimum_size = Vector2(0, h)
    return c

## A panel with a vertical box inside. Returns the inner box to add children to.
func card(parent: Node, min_size: Vector2 = Vector2.ZERO, expand: bool = false) -> VBoxContainer:
    var pc := PanelContainer.new()
    pc.custom_minimum_size = min_size
    if expand:
        pc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        pc.size_flags_vertical = Control.SIZE_EXPAND_FILL
    parent.add_child(pc)
    var v := VBoxContainer.new()
    v.add_theme_constant_override("separation", 10)
    pc.add_child(v)
    return v

## Back button + title along the top of the screen.
func top_bar(title: String, back_text: String = "", back_cb: Callable = Callable()) -> HBoxContainer:
    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 16)
    main.add_child(row)
    if back_text != "":
        row.add_child(btn(back_text, back_cb, Vector2(200, 44)))
    row.add_child(lbl(title, 36, Palette.ACCENT_HOVER))
    return row

func add_centered(width: int = 400) -> VBoxContainer:
    var center := CenterContainer.new()
    add_child(center)
    center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var box := VBoxContainer.new()
    box.custom_minimum_size = Vector2(width, 0)
    box.add_theme_constant_override("separation", 12)
    center.add_child(box)
    return box

func rect(parent: Node, pos: Vector2, sz: Vector2, color: Color) -> ColorRect:
    var r := ColorRect.new()
    r.position = pos
    r.size = sz
    r.color = color
    r.mouse_filter = Control.MOUSE_FILTER_IGNORE
    parent.add_child(r)
    return r

func tag(parent: Control, text: String) -> Label:
    var l := lbl(text, 14)
    l.position = Vector2(6, 4)
    parent.add_child(l)
    return l

func clear(node: Node) -> void:
    for c in node.get_children():
        node.remove_child(c)
        c.queue_free()
