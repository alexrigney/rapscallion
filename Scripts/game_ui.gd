extends Control

# ---/NODE VARIABLES/---
@onready var text_log: RichTextLabel = %TextLog
@onready var room_row: HBoxContainer = %RoomRow
@onready var hp_label: Label = %HpLabel
@onready var gold_label: Label = %GoldLabel
@onready var room_number_label: Label = %RoomNumberLabel

@onready var deck_label_: RichTextLabel = %DeckLabel
@onready var weapon_label: RichTextLabel = %Weapon
@onready var limit_label: Label = %WeaponLimitLabel
@onready var potion_label: RichTextLabel = %Potion
@onready var discard_label: RichTextLabel = %DiscardLabel

@onready var next_room_btn: Button = %NextRoomBtn

@onready var low_ceiling_barehand: Label = %LowCeilingBarehandPrompt
@onready var no_weapon_barehand: Label = %NoWeaponBarehandPrompt
@onready var choose_barehand: Label = %ChooseBarehandPrompt
@onready var flee_prompt: Label = %FleePrompt

@onready var yes_no_container: VBoxContainer = %YesNoContainer
@onready var bh_yes_no_row: HBoxContainer = %BHYesNoRow
@onready var flee_yes_no_row: HBoxContainer = %FleeYesNoRow

@onready var game_over_screen: Panel = %GameOverScreen
@onready var player_wins_screen: Panel = %PlayerWinsScreen

@onready var card_theme: Theme = preload("res://Themes/card_theme.tres")

@onready var state: GameState = $GameState

# ---/CONSTANTS/---
const CARD_SCN: PackedScene = preload("res://Scenes/card.tscn")


func _ready() -> void:
	state.log_text.connect(say)
	state.room_updated.connect(_on_room_updated)
	state.next_room.connect(move_next)
	state.stats_changed.connect(_on_stats_changed)
	state.inventory_changed.connect(_on_inventory_changed)
	state.barehand_prompt.connect(_on_barehand_prompt)
	state.flee_prompt.connect(_on_flee_prompt)
	state.game_over.connect(_on_game_over)
	state.player_wins.connect(_on_player_wins)
	state.start_game()


func say(text: String) -> void:
	text_log.append_text(text)


func _on_room_updated(room: Array) -> void:
	for child in room_row.get_children():
		child.queue_free()
		
	var counter: int = 0

	for key in room:
		var card := CARD_SCN.instantiate() as Card
		room_row.add_child(card)
		print(card)
		card.set_card(key)

		if room[int(counter)] == key:
			var card_btn = card.get_child(0)
			card_btn.name = "btn_" + str(counter)
			card_btn.pressed.connect(_on_btn_card_pressed.bind(card_btn.name))
			counter += 1


func move_next(_next_room) -> void:
	next_room_btn.visible = true


func _on_stats_changed(hp: int, max_hp: int, gold: int, room_number: int, deck: Array, deck_max: int, discard: Array, weapon_limit: int, _limit_not_set: bool) -> void:
	hp_label.text = "HP: %d/%d" % [hp, max_hp]
	gold_label.text = "GOLD: %d" % [gold]
	deck_label_.text = "%d/%d" % [deck.size(), deck_max]
	discard_label.text = "%d" % [discard.size()]
	room_number_label.text = "ROOM: %d" % [room_number]
	
	if _limit_not_set == true:
		limit_label.text = ""
	else:
		limit_label.text = "LIMIT: " + str(weapon_limit)


func _on_inventory_changed(weapon: Dictionary, potion: Dictionary) -> void:
	if weapon == {}:
		weapon_label.text = "--"
	else:
		weapon_label.text = "--"
		weapon_label.text = weapon.id
		weapon_label.add_theme_color_override("font_color", Color.CRIMSON)
	if potion == {}:
		potion_label.text = "--"
	else:
		potion_label.text = str(potion.id)


func _on_barehand_prompt(weapon: Dictionary, _choose_barehanded: bool) -> void:
	#yes_no_container.visible = true
	bh_yes_no_row.visible = true
	
	if _choose_barehanded == true:
		choose_barehand.visible = true
		return
	elif weapon == {}:
		no_weapon_barehand.visible = true
	else:
		low_ceiling_barehand.visible = true


func _on_flee_prompt() -> void:
	#yes_no_container.visible = true
	flee_prompt.visible = true
	flee_yes_no_row.visible = true


func _on_game_over(_game_over: bool) -> void:
	if _game_over == true:
		game_over_screen.visible = true


func _on_player_wins(_player_wins: bool) -> void:
	if _player_wins == true:
		player_wins_screen.visible = true


func _on_btn_card_pressed(button: String) -> void:
	match button:
		"btn_0":
			state.handle_command("first")
		"btn_1":
			state.handle_command("second")
		"btn_2":
			state.handle_command("third")
		"btn_3":
			state.handle_command("fourth")


func _on_next_room_btn_pressed() -> void:
	next_room_btn.visible = false
	state._ui_locked = false
	state._next_room = false
	state.refill()


func _on_barehand_yes_pressed() -> void:
	#yes_no_container.visible = false
	no_weapon_barehand.visible = false
	low_ceiling_barehand.visible = false
	choose_barehand.visible = false
	bh_yes_no_row.visible = false
	
	state.handle_command("bh_yes")


func _on_barehand_no_pressed() -> void:
	#yes_no_container.visible = false
	no_weapon_barehand.visible = false
	low_ceiling_barehand.visible = false
	choose_barehand.visible = false
	bh_yes_no_row.visible = false
	
	state.handle_command("bh_no")


func _on_barehand_toggle_toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		state._choose_barehanded = true
	else:
		state._choose_barehanded = false


func _on_btn_yes_flee_pressed() -> void:
	#yes_no_container.visible = false
	flee_prompt.visible = false
	flee_yes_no_row.visible = false
	
	state.handle_command("flee_yes")

func _on_btn_no_flee_pressed() -> void:
	#yes_no_container.visible = false
	flee_prompt.visible = false
	flee_yes_no_row.visible = false

	state.handle_command("flee_no")
