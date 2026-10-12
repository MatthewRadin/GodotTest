extends BaseScreen

func build() -> void:
    var earned := Game.score_day()
    var box := add_centered(520)
    box.add_child(lbl("End of Day %d" % Game.day, 44, Palette.ACCENT_HOVER, HORIZONTAL_ALIGNMENT_CENTER))
    var c := card(box)
    c.add_child(lbl("Value of items bought: $%d" % int(Game.stats["bought"]), 22))
    c.add_child(lbl("Value of items sold: $%d" % int(Game.stats["sold"]), 22))
    var sellers := int(Game.stats["sellers"])
    var buyers := int(Game.stats["buyers"])
    c.add_child(lbl("Customers: %d   (sellers: %d, buyers: %d)" % [sellers + buyers, sellers, buyers], 22))
    c.add_child(lbl("Levels earned: %d" % earned, 28, Palette.GOOD))
    box.add_child(btn("Next >", _next, Vector2(0, 52)))

func _next() -> void:
    Game.goto("upgrades")
