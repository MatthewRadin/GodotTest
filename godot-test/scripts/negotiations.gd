extends BaseScreen

var slider: HSlider
var price_lbl: Label
var offer_lbl: Label
var reply_lbl: Label
var accept_btn: Button

func build() -> void:
    if Game.current_item.is_empty():
        Game.go_shop()                 # nobody is at the desk
        return
    var item: Dictionary = Game.current_item
    var selling := Game.current_mode == "sell"
    top_bar("Negotiations", "< Return to Shop", Game.go_shop)

    var row := HBoxContainer.new()
    row.size_flags_vertical = Control.SIZE_EXPAND_FILL
    row.add_theme_constant_override("separation", 16)
    main.add_child(row)

    var left := card(row, Vector2(340, 0))
    left.add_child(lbl("On the desk:", 18, Palette.MUTED))
    left.add_child(btn(str(item["name"]) + "\n\n(click to inspect)", _inspect, Vector2(300, 260)))

    var right := card(row, Vector2.ZERO, true)
    var intro := "A customer wants to SELL you this item." if selling else "A customer wants to BUY this item from you."
    right.add_child(lbl(intro, 24))
    right.add_child(lbl("Placeholder dialogue: \"Hello! Interested in making a deal?\"", 18, Palette.MUTED))
    price_lbl = lbl("", 32, Palette.ACCENT_HOVER)
    right.add_child(price_lbl)

    slider = HSlider.new()
    slider.step = 1
    slider.custom_minimum_size = Vector2(420, 28)
    slider.value_changed.connect(_on_slider)
    right.add_child(slider)
    offer_lbl = lbl("", 20)
    right.add_child(offer_lbl)

    reply_lbl = lbl("", 20, Palette.GOOD)
    right.add_child(reply_lbl)

    var buttons := HBoxContainer.new()
    buttons.add_theme_constant_override("separation", 12)
    right.add_child(buttons)
    buttons.add_child(btn("Make Offer", _make_offer, Vector2(170, 48)))
    accept_btn = btn("Accept", _accept, Vector2(170, 48))
    buttons.add_child(accept_btn)
    buttons.add_child(btn("Decline", _decline, Vector2(170, 48)))
    _refresh_range()

func _refresh_range() -> void:
    var p: int = Game.current_price
    slider.max_value = 100000.0          # widen first so min/max can be set in any order
    if Game.current_mode == "sell":
        slider.min_value = maxi(1, int(p * 0.4))
        slider.max_value = maxi(p, 2)
    else:
        slider.min_value = p
        slider.max_value = maxi(p + 10, int(Game.item_value(Game.current_item) * 1.8))
    slider.value = p
    price_lbl.text = "Current price: $%d" % p
    accept_btn.text = "Accept $%d" % p
    offer_lbl.text = "Your offer: $%d" % int(slider.value)

func _on_slider(v: float) -> void:
    offer_lbl.text = "Your offer: $%d" % int(v)

func _make_offer() -> void:
    var offer := int(slider.value)
    var result := Game.evaluate_offer(offer)
    reply_lbl.add_theme_color_override("font_color", Palette.GOOD)
    if result["accepted"]:
        Game.current_price = offer
        reply_lbl.text = "Customer: \"Deal! (placeholder)\""
    else:
        var counter: int = result["counter"]
        if counter == Game.current_price:
            reply_lbl.text = "Customer: \"That's my final price.\""
        else:
            Game.current_price = counter
            reply_lbl.text = "Customer: \"How about $%d?\"" % counter
    _refresh_range()

func _accept() -> void:
    if Game.finish_deal(true) == "no_cash":
        reply_lbl.text = "You can't afford that. Try a lower price!"
        reply_lbl.add_theme_color_override("font_color", Palette.BAD)
        return
    Game.go_shop()

func _decline() -> void:
    Game.finish_deal(false)
    Game.go_shop()

func _inspect() -> void:
    Game.goto_from("inspection", "negotiations")
