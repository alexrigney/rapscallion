extends Node
class_name GameState

# ---/SIGNALS/---
signal log_text(text: String)

signal stats_changed(hp, max_hp, gold, room_number, deck, deck_max, discard)
signal inventory_changed(weapon: Dictionary, potion: Dictionary)

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
var card_count = 0
var card_position = 0
var room_number = 0

var _next_room = false
var _game_over = false
var _player_wins = false
var _ui_locked = false

# ---/CARD STATE/---
var weapon = {}
var potion = {}

var card_retained = {}
var retained_position = 0

# ---/ARRAY VARIABLES/---
var deck: Array = []
var room: Array = []
var inventory: Array = [weapon, potion]
var enemies: Array = []
var discard: Array = []

# ---/CARD DATA/---
var card_data: Dictionary = {
	SPADES:{
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
}

# ---/LIFECYCLE/---
func start_game() -> void:
	generate_deck()
	_emit_inventory()

# ---/EMISSIONS/---
func _say(text: String) -> void:
	emit_signal("log_text", text)

func _emit_inventory() -> void:
	inventory = [weapon, potion]
	emit_signal("inventory_changed", weapon, potion)

func _emit_room() -> void:
	emit_signal("room_updated", room)

func _emit_next_room() -> void:
	_next_room = true
	_ui_locked = true
	emit_signal("next_room", _next_room)

func _emit_stats() -> void:
	emit_signal("stats_changed", hp, max_hp, gold, room_number, deck, deck_max, discard)

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
					card_count = 0

func handle_command(command: String) -> void:
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
			flee()

# ---/ROOM HELPERS/
func generate_deck() -> void:
	for key in card_data:
		for values in card_data[key]:
			var card_values = card_data[key][values]
			card_values["suit"] = key
			card_values["id"] = (card_values.suit + card_values.id)
			var suit = card_values.suit
			var card_name = card_values.name
		
			if suit == SPADES:
				card_values.name = (card_name + " of Spades")
			elif suit == CLUBS:
				card_values.name = (card_name + " of Clubs")
			elif suit == HEARTS:
				card_values.name = (card_name + " of Hearts")
			else:
				card_values.name = (card_name + " of Diamonds")
			card_values.erase("suit")
			deck.append(card_values)
	
	deck.shuffle()
	deck_max = deck.size()
	deck_count = deck.size()
	_emit_stats()
	fill()

func fill() -> void:
	deck.resize(6)
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
		print("DECK BEFORE END: " + str(deck))
		print("\nROOM BEFORE END: " + str(room))
		var final_room: Array = []
		final_room.resize(4)
		print("\nEMPTY COPY PROOF: " + str(final_room))
		for c in room:
			if c == {}:
				if deck.size() > 0:
					var card = deck[0]
					print("\nCARD TO BE DRAWN: " + str(card.id))
					var position = room.find(c)
					print("\nFOUND VACANCY AT POSITION " + str(position) + " IN ROOM")
					print("\nEMULATING VACANT VALUE'S POSITION IN ROOM COPY")
					print("\nDREW & INSERTED " + str(card.id) + " AT POSITION " + str(position) + " IN ROOM COPY")
					final_room.insert(position, card)
					deck.remove_at(0)
					print("\nDECK SIZE: " + str(deck.size()))
					print("\nROOM COPY AFTER CARD APPENDED: " + str(final_room))
					room[position] = {0:0}
				elif deck.size() == 0:
						print("\nDECK EMPTY--APPENDING REMAINING VACANT VALUES TO ROOM COPY")
						var position = room.find(c)
						print("\nFOUND VACANCY AT POSITION " + str(position) + " IN ROOM")
						final_room.insert(position, c)
						print("\n" + str(c) + " INSERTED AT POSITION " + str(position) + " IN ROOM COPY")
						print("\nROOM COPY AFTER VACANCY APPENDED: " + str(final_room))
						room[position] = {0:0}
			elif c != {} and c != {0:0}:
					card_retained = c
					retained_position = room.find(c)
					final_room.insert(retained_position, card_retained)
					print("\nPROOF OF RETAINED CARD: " + str(card_retained.id) + " AT POSITION " + str(retained_position) + " IN ROOM")
					print("\nRETAINED " + str(card_retained) + " AND INSERTED INTO ROOM COPY AT POSITION " + str(retained_position))
		
		final_room.resize(4)
		room = final_room
		print("\nROOM COPY CLAMPED TO " + str(final_room.size()))
		print("\nPROOF OF EMPTY DECK: " + str(deck))
		print("\nROOM COPY AT END: " + str(final_room))
		print("PROOF OF NEW ROOM: " + str(room))
		#print("DECK BEFORE END: " + str(deck))
		#print("ROOM BEFORE END: " + str(room))
		#while deck.size() > 0:
			#var card = deck[0]
			#print("NEXT CARD: " + str(card))
			#for c in room:
				#if c == {}:
					#print("PROOF OF EMPTY: " + str(c))
					#c = card
					#print("PROOF OF OVERWRITE: " + str(c))
					#deck.remove_at(0)
		#print("DECK AFTER END: " + str(deck))
		#print("ROOM AFTER END: " + str(room))
		
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
		attack(card)
		
	elif card.type == "weapon":
		if weapon != {}:
			discard.append(weapon)
			_say("▻DISCARDED WEAPON (" + weapon.id + ")\n\n")
		weapon = card
		card_count += 1
		_say("▻EQUIPPED WEAPON (" + weapon.id + ")\n\n")
		
	elif card.type == "potion":
		if potion != {}:
			discard.append(potion)
			_say("▻DISCARDED POTION (" + potion.id + ")\n\n")
		potion = card
		card_count += 1
		_say("▻EQUIPPED POTION (" + potion.id + ")\n\n")
	
	_emit_stats()
	_emit_inventory()
	room[card_position] = {}
	_emit_room()
	
	if card_count == 3:
		_emit_next_room()
		card_count = 0

# ---/ACTIONS/---
func attack(enemy: Dictionary) -> void:
	var enemy_atk = enemy.value
	var old_hp = hp
	var weapon_dmg = 0

	if weapon != {}:
		weapon_dmg = weapon.value
	
	var dmg_taken = max(enemy_atk - weapon_dmg, 0)
	
	hp = max(old_hp - dmg_taken, 0)
	
	if hp == 0:
		_emit_game_over()
		return
	
	if weapon == {}:
		_say("▻YOU ATTACK BAREHANDED\n\n")
	else:
		_say("▻YOU ATTACK THE ENEMY (" + str(enemy.id) + ") WITH YOUR WEAPON (" + str(weapon.id) + ")\n\n")
		
	if dmg_taken == 0:
		_say("▻YOU TAKE NO DAMAGE\n\n")
	else:
		_say("▻(" + str(dmg_taken) + ") DAMAGE TAKEN\n\n")
	
	_say("▻ENEMY (" + str(enemy.id) + ") DEFEATED\n\n")
	
	if weapon != {}:
		discard.append(weapon)
		_say("▻WEAPON (" + str(weapon.id) + ") WAS DESTROYED\n\n")
	
	discard.append(enemy)
		
	weapon = {}
	card_count += 1
	_emit_inventory()
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
		_say("YOU CANNOT FLEE")
		return
	
	for card in room:
		if card != {}:
			deck.append(card)
	
	room.clear()
	fill()
	_say("▻YOU FLED THE ROOM\n\n")
