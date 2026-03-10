extends Control

@onready var text_log: RichTextLabel = %TextLog
@onready var room_row: HBoxContainer = %RoomRow
@onready var player_info: HBoxContainer = %PlayerInfo
@onready var hp_label: Label = %HpLabel
@onready var deck_label: Label = %DeckCountLabel
@onready var weapon_label: Label = %WeaponLabel
@onready var potion_label: Label = %PotionLabel

@onready var deck_label_: RichTextLabel = %DeckLabel
@onready var weapon_label_: RichTextLabel = %Weapon
@onready var potion_label_: RichTextLabel = %Potion
@onready var discard_label: RichTextLabel = %DiscardLabel


@onready var card_1: RichTextLabel = %Card1
@onready var card_2: RichTextLabel = %Card2
@onready var card_3: RichTextLabel = %Card3
@onready var card_4: RichTextLabel = %Card4

@onready var next_room_prompt: Panel = %NextRoomPrompt
@onready var next_room_btn: Button = %NextRoomBtn

@onready var game_over_screen: Panel = %GameOverScreen
@onready var player_wins_screen: Panel = %PlayerWinsScreen

@onready var card_theme: Theme = preload("res://Themes/card_theme.tres")

@onready var state: GameState = $GameState

func _ready() -> void:
	state.log_text.connect(say)
	state.room_updated.connect(_on_room_updated)
	state.next_room.connect(move_next)
	state.stats_changed.connect(_on_stats_changed)
	state.inventory_changed.connect(_on_inventory_changed)
	state.game_over.connect(_on_game_over)
	state.player_wins.connect(_on_player_wins)
	state.start_game()

func say(text: String) -> void:
	text_log.append_text(text)

func _on_room_updated(room: Array) -> void:
	for child in room_row.get_children():
		child.queue_free()
		
	for key in room:
		var c = RichTextLabel.new()
		if key != {}:
			c.text = key.id
		else:
			c.text = ""
		c.custom_minimum_size = Vector2(150, 210)
		c.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		c.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		c.theme = card_theme
		
		if key != {}:
			if key.type == "enemy":
				c.add_theme_color_override("default_color", Color(0.081, 0.081, 0.081, 1.0))
			else:
				c.add_theme_color_override("default_color", Color(0.706, 0.067, 0.188, 1.0))
		
		room_row.add_child(c)

func move_next(_next_room) -> void:
	pass

func _on_stats_changed(hp: int, max_hp: int, gold: int, deck_count: int, deck_max: int) -> void:
	hp_label.text = "HP: %d/%d" % [hp, max_hp]
	deck_label.text = "DECK: %d" % state.deck.size() + "/42"
	deck_label_.text = "%d" % state.deck.size() + "/42"
	discard_label.text = "%d" % state.discard.size()

func _on_inventory_changed(weapon: Dictionary, potion: Dictionary) -> void:
	if weapon == {}:
		weapon_label.text = "WEAPON: -- "
		weapon_label_.text = "--"
		weapon_label_.add_theme_color_override("default_color", Color.WHITE)
	else:
		weapon_label.text = "WEAPON: %s" % weapon.id
		weapon_label_.text = str(weapon.id)
		weapon_label_.add_theme_color_override("default_color", Color.CRIMSON)
	
	if potion == {}:
		potion_label.text = "POTION: -- "
		potion_label_.text = "--"
		potion_label_.add_theme_color_override("default_color", Color.WHITE)
	else:
		potion_label.text = "POTION: %s" % potion.id
		potion_label_.text = str(potion.id)
		weapon_label_.add_theme_color_override("default_color", Color.CRIMSON)
func _on_game_over(_game_over: bool) -> void:
	if _game_over == true:
		game_over_screen.visible = true

func _on_player_wins(_player_wins: bool) -> void:
	if _player_wins == true:
		player_wins_screen.visible = true


func _on_next_room_btn_pressed() -> void:
	state._ui_locked = false
	state._next_room = false
