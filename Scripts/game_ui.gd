extends Control

@onready var text_log: RichTextLabel = %TextLog
@onready var hp_label: Label = %HpLabel
@onready var deck_label: Label = %DeckCountLabel
@onready var weapon_label: Label = %WeaponLabel
@onready var potion_label: Label = %PotionLabel
@onready var card_1: Label = %Card1
@onready var card_2: Label = %Card2
@onready var card_3: Label = %Card3
@onready var card_4: Label = %Card4

@onready var game_over_screen: Panel = %GameOverScreen
@onready var state: GameState = $GameState


func _ready() -> void:
	state.log_text.connect(say)
	state.stats_changed.connect(_on_stats_changed)
	state.inventory_changed.connect(_on_inventory_changed)
	state.room_updated.connect(_on_room_updated)
	state.game_over.connect(_on_game_over)
	state.start_game()

func say(text: String) -> void:
	text_log.append_text(text)

func _on_room_updated(room: Array, deck: Array) -> void:
	card_1.text = str(room[0])
	card_2.text = str(room[1])
	card_3.text = str(room[2])
	card_4.text = str(room[3])

func _on_inventory_changed(weapon: String, potion: String) -> void:
	if weapon == null:
		weapon_label.text = "WEAPON: - "
	else:
		weapon_label.text = "WEAPON: %s" % weapon
	if potion == null:
		potion_label.text = "POTION: - "
	else:
		potion_label.text = "POTION: %s" % potion

func _on_stats_changed(hp: int, max_hp: int, gold: int, deck_count: int, deck_max: int) -> void:
	hp_label.text = "HP: %d/%d" % [hp, max_hp]
	deck_label.text = "DECK: %d" % state.deck.size() + "/42"

func _on_game_over(_game_over: bool) -> void:
	if _game_over == true:
		game_over_screen.visible = true
