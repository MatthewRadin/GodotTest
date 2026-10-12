extends Control

@onready var item_button: Button = %ItemButton
@onready var intro_label: Label = %IntroLabel
@onready var price_label: Label = %PriceLabel
@onready var offer_slider: HSlider = %OfferSlider
@onready var offer_label: Label = %OfferLabel
@onready var reply_label: Label = %ReplyLabel
@onready var accept_button: Button = %AcceptButton

func _ready() -> void:
    if Game.current_item.is_empty():
        Game.go_shop()                 # nobody is at the desk
        return
    item_button.text = str(Game.current_item["name"]) + "\n\n(click to inspect)"
    if Game.current_mode == "sell":
        intro_label.text = "A customer wants to SELL you this item."
    else:
        intro_label.text = "A customer wants to BUY this item from you."
    _refresh_range()

func _refresh_range() -> void:
    var p: int = Game.current_price
    offer_slider.max_value = 100000.0      # widen first so min/max can be set in any order
    if Game.current_mode == "sell":
        offer_slider.min_value = maxi(1, int(p * 0.4))
        offer_slider.max_value = maxi(p, 2)
    else:
        offer_slider.min_value = p
        offer_slider.max_value = maxi(p + 10, int(Game.item_value(Game.current_item) * 1.8))
    offer_slider.value = p
    price_label.text = "Current price: $%d" % p
    accept_button.text = "Accept $%d" % p
    offer_label.text = "Your offer: $%d" % int(offer_slider.value)

func _on_offer_slider_value_changed(v: float) -> void:
    offer_label.text = "Your offer: $%d" % int(v)

func _on_make_offer_button_pressed() -> void:
    var offer := int(offer_slider.value)
    var result := Game.evaluate_offer(offer)
    reply_label.add_theme_color_override("font_color", Palette.GOOD)
    if result["accepted"]:
        Game.current_price = offer
        reply_label.text = "Customer: \"Deal! (placeholder)\""
    else:
        var counter: int = result["counter"]
        if counter == Game.current_price:
            reply_label.text = "Customer: \"That's my final price.\""
        else:
            Game.current_price = counter
            reply_label.text = "Customer: \"How about $%d?\"" % counter
    _refresh_range()

func _on_accept_button_pressed() -> void:
    if Game.finish_deal(true) == "no_cash":
        reply_label.text = "You can't afford that. Try a lower price!"
        reply_label.add_theme_color_override("font_color", Palette.BAD)
        return
    Game.go_shop()

func _on_decline_button_pressed() -> void:
    Game.finish_deal(false)
    Game.go_shop()

func _on_item_button_pressed() -> void:
    Game.goto_from("inspection", "negotiations")

func _on_back_button_pressed() -> void:
    Game.go_shop()
