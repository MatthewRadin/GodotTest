extends Control

@onready var title: Label = %TitleLabel
@onready var bought_label: Label = %BoughtLabel
@onready var sold_label: Label = %SoldLabel
@onready var customers_label: Label = %CustomersLabel
@onready var levels_label: Label = %LevelsLabel

func _ready() -> void:
    var earned := Game.score_day()
    var sellers := int(Game.stats["sellers"])
    var buyers := int(Game.stats["buyers"])
    title.text = "End of Day %d" % Game.day
    bought_label.text = "Value of items bought: $%d" % int(Game.stats["bought"])
    sold_label.text = "Value of items sold: $%d" % int(Game.stats["sold"])
    customers_label.text = "Customers: %d   (sellers: %d, buyers: %d)" % [sellers + buyers, sellers, buyers]
    levels_label.text = "Levels earned: %d" % earned

func _on_next_button_pressed() -> void:
    Game.goto("upgrades")
