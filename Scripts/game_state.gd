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
const HEARTS = "♥"
const DIAMONDS = "♦"

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
var card_data: Dictionary = {
	SPADES:{
		"A":	{"id":"A", "name":"Ace", "type":"enemy" , "value":14, "asset_id":"s1"},
		"K":	{"id":"K", "name":"King", "type":"enemy", "value":13},
		"Q":	{"id":"Q", "name":"Queen", "type":"enemy", "value":12},
		"J":	{"id":"J", "name":"Jack", "type":"enemy", "value":11},
		"10":	{"id":"10", "name":"Ten", "type":"enemy", "value":10},
		"9":	{"id":"9", "name":"Nine", "type":"enemy", "value":9},
		"8":	{"id":"8", "name":"Eight", "type":"enemy", "value":8},
		"7":	{"id":"7", "name":"Seven", "type":"enemy", "value":7},
		"6":	{"id":"6", "name":"Six", "type":"enemy", "value":6},
		"5":	{"id":"5", "name":"Five", "type":"enemy", "value":5},
		"4":	{"id":"4", "name":"Four", "type":"enemy", "value":4},
		"3":	{"id":"3", "name":"Three", "type":"enemy", "value":3},
		"2":	{"id":"2", "name":"Two", "type":"enemy","value":2}
		},
	CLUBS:{
		"A":	{"id":"A", "name":"Ace", "type":"enemy" , "value":14},
		"K":	{"id":"K", "name":"King", "type":"enemy", "value":13},
		"Q":	{"id":"Q", "name":"Queen", "type":"enemy", "value":12},
		"J":	{"id":"J", "name":"Jack", "type":"enemy", "value":11},
		"10":	{"id":"10", "name":"Ten", "type":"enemy", "value":10},
		"9":	{"id":"9", "name":"Nine", "type":"enemy", "value":9},
		"8":	{"id":"8", "name":"Eight", "type":"enemy", "value":8},
		"7":	{"id":"7", "name":"Seven", "type":"enemy", "value":7},
		"6":	{"id":"6", "name":"Six", "type":"enemy", "value":6},
		"5":	{"id":"5", "name":"Five", "type":"enemy", "value":5},
		"4":	{"id":"4", "name":"Four", "type":"enemy", "value":4},
		"3":	{"id":"3", "name":"Three", "type":"enemy", "value":3},
		"2":	{"id":"2", "name":"Two", "type":"enemy", "value":2}
	},
	HEARTS:{
		"10":	{"id":"10", "name":"Ten", "type":"potion", "value":10},
		"9":	{"id":"9", "name":"Nine", "type":"potion", "value":9},
		"8":	{"id":"8", "name":"Eight", "type":"potion", "value":8},
		"7":	{"id":"7", "name":"Seven", "type":"potion", "value":7},
		"6":	{"id":"6", "name":"Six", "type":"potion", "value":6},
		"5":	{"id":"5", "name":"Five", "type":"potion", "value":5},
		"4":	{"id":"4", "name":"Four", "type":"potion", "value":4},
		"3":	{"id":"3", "name":"Three", "type":"potion", "value":3},
		"2":	{"id":"2", "name":"Two", "type":"potion", "value":2}
	},
	DIAMONDS:{
		"10":	{"id":"10", "name":"Ten", "type":"weapon", "value":10},
		"9":	{"id":"9", "name":"Nine", "type":"weapon", "value":9},
		"8":	{"id":"8", "name":"Eight", "type":"weapon", "value":8},
		"7":	{"id":"7", "name":"Seven", "type":"weapon", "value":7},
		"6":	{"id":"6", "name":"Six", "type":"weapon", "value":6},
		"5":	{"id":"5", "name":"Five", "type":"weapon", "value":5},
		"4":	{"id":"4", "name":"Four", "type":"weapon", "value":4},
		"3":	{"id":"3", "name":"Three", "type":"weapon", "value":3},
		"2":	{"id":"2", "name":"Two", "type":"weapon", "value":2}
	}


#var card_suit: Dictionary = {
	#{"suit":"♠"}
	#{SPADES
	#"♥"
	#"♦"
}
var card_rank: Dictionary ={
	"A":	{"id":"A", "type":"enemy" , "value":14, "asset_id":"s1"},
	"K":	{"id":"K", "type":"enemy", "value":13},
	"Q":	{"id":"Q", "type":"enemy", "value":12},
	"J":	{"id":"J", "type":"enemy", "value":11},
	"10":	{"id":"10", "type":"weapon", "value":10},
	"9":	{"id":"9", "type":"weapon", "value":9},
	"8":	{"id":"8", "type":"weapon", "value":8},
	"7":	{"id":"7", "type":"weapon", "value":7},
	"6":	{"id":"6", "type":"weapon", "value":6},
	"5":	{"id":"5", "type":"weapon", "value":5},
	"4":	{"id":"4", "type":"weapon", "value":4},
	"3":	{"id":"3", "type":"weapon", "value":3},
	"2":	{"id":"2", "type":"weapon", "value":2}
}


# ---/LIFECYCLE/---
func start_game() -> void:
	generate_deck()
	_emit_inventory()


# ---/EMISSIONS/---
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


# ---/INPUT HANDLING/---
func _unhandled_input(event: InputEvent) -> void:
	if _ui_locked == false:
		if event is InputEventKey and event.pressed and not event.echo:
			match event.keycode:
				KEY_1:
					print("key1")
					handle_command("first")
				KEY_2:
					print("key2")
					handle_command("second")
				KEY_3:
					print("key3")
					handle_command("third")
				KEY_4:
					print("key4")
					handle_command("fourth")
				KEY_P:
					print("keyP")
					handle_command("heal")
				KEY_F:
					print("keyF")
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
	for key in card_data:
		for values in card_data[key]:
			var card_values = card_data[key][values]
			card_values["suit"] = key
			card_values["id"] = (card_values.suit + card_values.id)
			var suit = card_values.suit
			match suit:
				SPADES:
					card_values["asset_id"] = "s" + str(card_values.value)
				CLUBS:
					card_values["asset_id"] = "c" + str(card_values.value)
				HEARTS:
					card_values["asset_id"] = "h" + str(card_values.value)
				DIAMONDS:
					card_values["asset_id"] = "d" + str(card_values.value)
			
			card_values.erase("suit")
			deck.append(card_values)
	
	deck.shuffle()
	deck_max = deck.size()
	deck_count = deck.size()
	_emit_stats()
	fill()


func fill() -> void:
	while room.size() < 4:
		room.append(deck[0])
		deck.remove_at(0)
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
	_say("▻ENEMY (" + str(enemy.id) + ") DEFEATED")
	
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
