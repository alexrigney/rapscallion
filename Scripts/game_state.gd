extends Node
class_name GameState

# ---/SIGNALS/---
signal log_text(text: String)

# ---/CONSTANTS/---
const SPADES = "♠"
const CLUBS = "♣"
const HEARTS = "♥"
const DIAMONDS = "♦"

# ---/NUMBER VARIABLES/---
var hp = 20
var max_hp = 20
var gold = 0

var card_position: int = 4

# ---/ARRAY VARIABLES/---
var deck: Array = []
var deck_symbols: Array = []

var room: Array = []
var room_symbols: Array = []

var items: Array = []
var items_symbols: Array = []

var enemies: Array = []
var enemies_symbols:Array = []

var discard: Array = []
var discard_symbols: Array = []


var card_data: Dictionary = {
	SPADES:{
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
	enter_room()

# ---/EMISSIONS/---
func _say(text: String) -> void:
	emit_signal("log_text", text)

func _emit_items() -> void:
	_emit_symbols()
	if items_symbols == []:
		_say("ITEMS: ")
	else:
		_say("ITEMS: " + str(items_symbols) + "\n\n")

func _emit_room() -> void:
	_emit_symbols()
	_say("ROOM: " + str(room_symbols) + "\n\n")
	_emit_items()

func _emit_symbols() -> void:
	deck_symbols.clear()
	room_symbols.clear()
	items_symbols.clear()

	for key in deck:
		var card = key
		var symbol = card.id
		deck_symbols.append(symbol)
		
	for key in room:
		var card = key
		var symbol = card.id
		room_symbols.append(symbol)
		
	for key in items:
		var card = key
		var symbol = card.id
		items_symbols.append(symbol)

# ---/INPUT HANDLING/---
func _unhandled_input(event: InputEvent) -> void:
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

func handle_command(command: String) -> void:
	match command:
		"first":
			card_position = 0
		"second":
			card_position = 1
		"third":
			card_position = 2
		"fourth":
			card_position = 3
	choose_card()

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
	_say("The deck has been shuffled.\n\n")

func fill_room() -> void:
	while room.size() < 4:
		var card = deck[0]
		room.append(card)
		deck.remove_at(0)
	_emit_room()

func choose_card() -> void:
	var card = room[card_position]
	if card.type == "enemy":
		attack(card)
	else:
		var symbol = card.id
		items.append(card)
		_say("Added " + symbol + " to your inventory.\n\n")
		_emit_items()
	
	room.remove_at(card_position)
	card_position = 4
	_emit_room()

#func sort_room() -> void:
	#var enemy_symbols: Array = []
	#var hand_symbols: Array = []
	#while enemies.size() < 4:
		#for card in room:
			#if card.id.find(SPADES) != -1 or card.id.find(CLUBS) != -1:
				#enemies.append(card)
				#enemy_symbols.append(card.id)
				#_say("An enemy has appeared: " + card.id)
			#else:
				#if hand.size() < 4:
					#hand.append(card)
					#hand_symbols.append(card.id)
					#_say("You've drawn " + card.id)
				#else:
					#discard.append(card)
					#_say(card.id + " has been discarded. Hand too full.")
					#_say("You've drawn " + card.id)
	#_say("ENEMIES: " + str(enemy_symbols))
	#_say("ITEMS: " + str(hand_symbols))

func enter_room() -> void:
	generate_deck()
	fill_room()

# ---/ACTIONS/---
func attack(enemy: Array) -> void:
	pass
	
func add_item(item: Array) -> void:
	items.append(item)
