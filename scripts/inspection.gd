extends Control

const EXPERT_COST := 20

@onready var content: Control = %Content
@onready var empty_label: Label = %EmptyLabel
@onready var name_label: Label = %NameLabel
@onready var desc_label: Label = %DescLabel
@onready var condition_label: Label = %ConditionLabel
@onready var damage_label: Label = %DamageLabel
@onready var value_label: Label = %ValueLabel
@onready var expert_button: Button = %ExpertButton

var item: Dictionary

func _ready() -> void:
    item = Game.current_item
    content.visible = not item.is_empty()
    empty_label.visible = item.is_empty()
    if item.is_empty():
        return
    expert_button.text = "Call an Expert ($%d)" % EXPERT_COST
    name_label.text = str(item["name"])
    desc_label.text = str(item["desc"])
    var q := float(item["quality"])
    condition_label.text = "Condition: %s  (%d / 100)" % [Game.condition_name(q), int(q)]
    damage_label.text = "Damage: " + ", ".join(PackedStringArray(item["defects"]))
    _refresh_value()

func _refresh_value() -> void:
    var v := Game.item_value(item)
    if item.get("appraised", false):
        value_label.text = "Expert appraisal: $%d" % v
        expert_button.disabled = true
    else:
        value_label.text = "Estimated value: $%d - $%d" % [int(v * 0.7), int(v * 1.3)]

func _on_expert_button_pressed() -> void:
    if Game.cash < EXPERT_COST:
        value_label.text = "Not enough cash for an expert."
        return
    Game.cash -= EXPERT_COST
    item["appraised"] = true
    _refresh_value()

func _on_back_button_pressed() -> void:
    Game.back()
