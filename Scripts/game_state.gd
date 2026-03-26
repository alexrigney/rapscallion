extends Node
class_name GameState

# ---/SIGNALS/---
signal log_text(text: String)

signal stats_changed(hp, max_hp, gold, room_number, deck, deck_max, discard, weapon_limit: int, _limit_not_set: bool)
signal inventory_changed(weapon: Dictionary, potion: Dictionary)
signal barehand_prompt(weapon: Dictionary, _choose_barehanded: bool)
signal flee_prompt()

signal room_updated(room: Array)

signal next_room(_next_room)
signal game_over(_game_over)
signal player_wins(_player_wins)

# ---/CONSTANTS/---
const SPADES = "♠"
const CLUBS = "♣"
const DIAMONDS = "♦"
const HEARTS = "♥"

const SUIT_ROW := {
	"HEARTS": 0,
	"DIAMONDS": 1,
	"CLUBS": 2,
	"SPADES": 3
}

const RANK_COL := {
	"A": 0,
	"2": 1,
	"3": 2,
	"4": 3,
	"5": 4,
	"6": 5,
	"7": 6,
	"8": 7,
	"9": 8,
	"10": 9,
	"J": 10,
	"Q": 11,
	"K": 12
}

const CARD_W := 23
const CARD_H := 35
const GAP_X := 1
const GAP_Y := 1
const START_X := 0
const START_Y := 0

# ---/NUMBER VARIABLES/---
var hp = 1000
var max_hp = 1000
var gold = 0
var deck_count: int = 0
var deck_max: int = 0
var card_position = 0
var room_number = 0

# ---/BOOLEANS/---
var _limit_not_set = true
var _choose_barehanded = false
var _next_room = false
var _awaiting_yes_no = false
var _game_over = false
var _player_wins = false
var _ui_locked = false

# ---/CARD STATE/---
var weapon = {}
var potion = {}

var card_retained = {}
var retained_position = 0

var weapon_limit: int = 14

# ---/ARRAY VARIABLES/---
var deck: Array = []
var room: Array = []
var discard: Array = []
var enemy: Dictionary = {}

# ---/CARD DATA/---
var card_suit: Dictionary = {
	"SPADES":	{"suit": "SPADES", "symbol":SPADES, "type":"enemy"},
	"CLUBS":	{"suit": "CLUBS", "symbol":CLUBS, "type":"enemy"},
	"DIAMONDS":	{"suit": "DIAMONDS", "symbol":DIAMONDS, "type":"weapon"},
	"HEARTS":	{"suit": "HEARTS", "symbol":HEARTS, "type":"potion"}
}

var card_rank: Dictionary = {
	"A": {"rank":"A", "value":14},
	"K": {"rank":"K", "value":13},
	"Q": {"rank":"Q", "value":12},
	"J": {"rank":"J", "value":11},
	"10": {"rank":"10", "value":10},
	"9": {"rank":"9", "value":9},
	"8": {"rank":"8", "value":8},
	"7": {"rank":"7", "value":7},
	"6": {"rank":"6", "value":6},
	"5": {"rank":"5", "value":5},
	"4": {"rank":"4", "value":4},
	"3": {"rank":"3", "value":3},
	"2": {"rank":"2", "value":2}
}


# ---/LIFECYCLE/---
func start_game() -> void:
	generate_deck()
	_emit_inventory()


# ---/EMISSIONS/---
#region
func _say(text: String) -> void:
	emit_signal("log_text", text)


func _emit_inventory() -> void:
	emit_signal("inventory_changed", weapon, potion,)


func _emit_room() -> void:
	emit_signal("room_updated", room)
	var empty_slots = room.count({})
	if empty_slots >= 3:
		_emit_next_room()


func _emit_next_room() -> void:
	_next_room = true
	_ui_locked = true
	emit_signal("next_room", _next_room)


func _emit_stats() -> void:
	emit_signal("stats_changed", hp, max_hp, gold, room_number, deck, deck_max, discard, weapon_limit, _limit_not_set)


func _emit_barehand_prompt() -> void:
	_awaiting_yes_no = true
	emit_signal("barehand_prompt", weapon, _choose_barehanded)


func _emit_flee_prompt() -> void:
	_awaiting_yes_no = true
	emit_signal("flee_prompt")


func _emit_game_over() -> void:
	_game_over = true
	emit_signal("game_over", _game_over)


func _emit_win() -> void:
	_player_wins = true
	emit_signal("player_wins", _player_wins)
#endregion


# ---/INPUT HANDLING/---
func _unhandled_input(event: InputEvent) -> void:
	if _ui_locked == false:
		if event is InputEventKey and event.pressed and not event.echo:
			match event.keycode:
				KEY_1:
					handle_command("first")
				KEY_2:
					handle_command("second")
				KEY_3:
					handle_command("third")
				KEY_4:
					handle_command("fourth")
				KEY_P:
					handle_command("heal")
				KEY_F:
					handle_command("flee")


func handle_command(command: String) -> void:
	if _awaiting_yes_no == false:
		match command:
			"first":
				card_position = 0
				choose_card()
			"second":
				card_position = 1
				choose_card()
			"third":
				card_position = 2
				choose_card()
			"fourth":
				card_position = 3
				choose_card()
			"heal":
				use_potion()
			"flee":
				_emit_flee_prompt()
	match command:
		"bh_yes":
			_awaiting_yes_no = false
			barehand()
		"bh_no":
			_awaiting_yes_no = false
			return
		"flee_yes":
			_awaiting_yes_no = false
			flee()
		"flee_no":
			_awaiting_yes_no = false
			return

# ---/ROOM HELPERS/
func generate_deck() -> void:
	for suit_data in card_suit:
		var symbol = card_suit[suit_data]["symbol"]
		var suit = card_suit[suit_data]["suit"]
		var type = card_suit[suit_data]["type"]
		
		for rank_data in card_rank:
			var rank = card_rank[rank_data]["rank"]
			var value = card_rank[rank_data]["value"]
			var card = {}
			
			card["id"] = (symbol + rank)
			card["rank"] = rank
			card["suit"] = suit
			card["type"] = type
			card["value"] = value
			
			if card["type"] != "enemy":
				if card["value"] > 10:
					continue
					
			deck.append(card)
	
	
	for card in deck:
		match card.suit:
			"SPADES":
				card["asset_id"] = "spades_" + str(card.value)
			"CLUBS":
				card["asset_id"] = "clubs_" + str(card.value)
			"DIAMONDS":
				card["asset_id"] = "diamonds_" + str(card.value)
			"HEARTS":
				card["asset_id"] = "hearts_" + str(card.value)
	
	print(deck)
	deck.shuffle()
	deck_count = deck.size()
	deck_max = deck.size()
	_emit_stats()
	fill()


func fill() -> void:
	while room.size() < 4:
		room.append(deck[0])
		deck.remove_at(0)
	print(room)
	_emit_room()
	_emit_stats()


func refill() -> void:
	if deck.size() > 2:
		for c in room:
			if c != {}:
				card_retained = c
				retained_position = room.find(c)
		room.clear()
		while room.size() < 3:
			room.append(deck[0])
			deck.remove_at(0)
		room.insert(int(retained_position), card_retained)
	else:
		var final_room: Array = []
		final_room.resize(4)
		for c in room:
			if c == {}:
				if deck.size() > 0:
					var card = deck[0]
					var position = room.find(c)
					final_room.insert(position, card)
					deck.remove_at(0)
					room[position] = {0:0}
				elif deck.size() == 0:
						var position = room.find(c)
						final_room.insert(position, c)
						room[position] = {0:0}
			elif c != {} and c != {0:0}:
					card_retained = c
					retained_position = room.find(c)
					final_room.insert(retained_position, card_retained)
		
		final_room.resize(4)
		room = final_room
		
	room_number += 1
		
	_emit_room()
	_emit_stats()
	
	if deck.size() == 0:
		_emit_room()
		_emit_win()


func choose_card() -> void:
	var card = room[card_position]
	
	if card == {}:
		return
		
	if card.type == "enemy":
		enemy = card
		if weapon != {} and _choose_barehanded == false:
			attack()
		elif weapon == {} or _choose_barehanded == true:
			_emit_barehand_prompt()
		return
		
	elif card.type == "weapon":
		if weapon != {}:
			discard.append(weapon)
			_say("▻DISCARDED WEAPON (" + weapon.id + ")\n\n")
		weapon = card
		_limit_not_set = true
		weapon_limit = 14
		_say("▻EQUIPPED WEAPON (" + weapon.id + ")\n\n")
		room[card_position] = {}
		
	elif card.type == "potion":
		if potion != {}:
			discard.append(potion)
			_say("▻DISCARDED POTION (" + potion.id + ")\n\n")
		potion = card
		_say("▻EQUIPPED POTION (" + potion.id + ")\n\n")
		room[card_position] = {}
	
	_emit_stats()
	_emit_inventory()
	_emit_room()


# ---/ACTIONS/---
func attack() -> void:
	var old_hp = hp
	var weapon_dmg = weapon.value
	
	if _limit_not_set == false and (enemy.value) > int(weapon_limit):
		_emit_barehand_prompt()
		return
	
	_say("▻YOU ATTACK THE ENEMY (" + str(enemy.id) + ") WITH YOUR WEAPON (" + str(weapon["id"]) + ")\n\n")
	
	var dmg_taken = max(enemy.value - weapon_dmg, 0)
	hp = max(old_hp - dmg_taken, 0)
	
	if hp == 0:
		_emit_game_over()
		return
	
	if dmg_taken == 0:
		_say("▻YOU TAKE NO DAMAGE\n\n")
	else:
		_say("▻(" + str(dmg_taken) + ") DAMAGE TAKEN\n\n")
	
	_say("▻ENEMY (" + str(enemy.id) + ") DEFEATED\n\n")
		
	discard.append(enemy)
	_limit_not_set = false
	weapon_limit = enemy.value
	
	_say("▻YOUR WEAPON CEILING IS NOW " + str(weapon_limit) +"\n\n")
	
	room[card_position] = {}
		
	_emit_stats()
	_emit_room()


func barehand() -> void:
	var old_hp = hp
	var dmg_taken = enemy.value
	hp = max(old_hp - dmg_taken, 0)
	
	_say("▻YOU ATTACK THE ENEMY (" + str(enemy.id) + ") BAREHANDED\n\n")
	_say("▻(" + str(dmg_taken) + ") DAMAGE TAKEN\n\n")
	_say("▻ENEMY (" + str(enemy.id) + ") DEFEATED\n\n")
	
	if hp == 0:
		_emit_game_over()
		return
		
	discard.append(enemy)

	room[card_position] = {}
	
	_emit_room()
	_emit_stats()


func use_potion() -> void:
	var old_hp = hp
	var heal_amount = 0
	
	if potion == {}:
		_say("▻NO POTION IN INVENTORY\n\n")
		return
	
	if potion != {}:
		heal_amount = int(potion.value)
	
	hp = min(old_hp + heal_amount, max_hp)
	
	_say("▻USED POTION (" + str(potion.id) + ") - GAINED " + str(heal_amount) + " HP\n\n")
	
	discard.append(potion)
	potion = {}
	
	_emit_inventory()
	_emit_stats()


func flee() -> void:
	if deck.size() < 4:
		_say("▻YOU CANNOT FLEE")
		return
	
	for card in room:
		if card != {}:
			deck.append(card)
	
	room.clear()
	fill()
	_say("▻YOU FLED THE ROOM\n\n")
