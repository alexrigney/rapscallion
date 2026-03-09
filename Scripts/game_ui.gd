extends Control

@onready var text_log: RichTextLabel = %TextLog
@onready var hp_label: Label = %HpLabel
@onready var deck_label: Label = %DeckCountLabel
@onready var weapon_label: Label = %WeaponLabel
@onready var potion_label: Label = %PotionLabel

@onready var deck_label_: RichTextLabel = %DeckLabel
@onready var weapon_label_: RichTextLabel = %Weapon
@onready var potion_label_: RichTextLabel = %Potion
@onready var discard_label: RichTextLabel = %DiscardLabel


@onready var card_1: Label = %Card1
@onready var card_2: Label = %Card2
@onready var card_3: Label = %Card3
@onready var card_4: Label = %Card4

@onready var game_over_screen: Panel = %GameOverScreen
@onready var player_wins_screen: Panel = %PlayerWinsScreen
@onready var state: GameState = $GameState


func _ready() -> void:
	state.log_text.connect(say)
	state.stats_changed.connect(_on_stats_changed)
	state.inventory_changed.connect(_on_inventory_changed)
	state.room_updated.connect(_on_room_updated)
	state.game_over.connect(_on_game_over)
	state.player_wins.connect(_on_player_wins)
	state.start_game()

func say(text: String) -> void:
	text_log.append_text(text)

func _on_room_updated(room: Array) -> void:
	card_1.text = str(room[0].id)
	card_2.text = str(room[1].id)
	card_3.text = str(room[2].id)
	card_4.text = str(room[3].id)

func _on_inventory_changed(weapon: Dictionary, potion: Dictionary) -> void:
	if weapon == {}:
		weapon_label.text = "WEAPON: - "
		weapon_label_.text = "--"
	else:
		weapon_label.text = "WEAPON: %s" % weapon.id
		weapon_label_.text = str(weapon.id)
	
	if potion == {}:
		potion_label.text = "POTION: - "
		potion_label_.text = "--"
	else:
		potion_label.text = "POTION: %s" % potion.id
		potion_label_.text = str(potion.id)

func _on_stats_changed(hp: int, max_hp: int, gold: int, deck_count: int, deck_max: int) -> void:
	hp_label.text = "HP: %d/%d" % [hp, max_hp]
	deck_label.text = "DECK: %d" % state.deck.size() + "/42"
	deck_label_.text = "%d" % state.deck.size() + "/42"
	discard_label.text = "%d" % state.discard.size()

func _on_game_over(_game_over: bool) -> void:
	if _game_over == true:
		game_over_screen.visible = true

func _on_player_wins(_player_wins: bool) -> void:
	if _player_wins == true:
		player_wins_screen.visible = true
