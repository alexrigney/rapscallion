extends Control

@onready var text_log: RichTextLabel = %TextLog
@onready var hp_label: Label = %HpLabel
@onready var deck_label: Label = %DeckCountLabel
@onready var state: GameState = $GameState


func _ready() -> void:
	state.log_text.connect(say)
	state.stats_changed.connect(_on_stats_changed)
	state.start_game()

func say(text: String) -> void:
	text_log.append_text(text)

func _on_stats_changed(hp: int, max_hp: int, gold: int, deck_count: int) -> void:
	hp_label.text = "HP: %d/%d" % [hp, max_hp]
	deck_label.text = "DECK: %d" % state.deck.size()
