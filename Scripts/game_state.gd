extends Node
class_name GameState

# ---/SIGNALS/---
signal log_text(text: String)
signal stats_changed(hp, max_hp, deck_count, deck_max, gold)
signal inventory_changed(weapon, potion)
signal room_updated(room_symbols: Array, deck: Array)
signal game_over(_game_over)

# ---/CONSTANTS/---
const SPADES = "♠"
const CLUBS = "♣"
const HEARTS = "♥"
const DIAMONDS = "♦"

# ---/NUMBER VARIABLES/---
var hp = 20
var max_hp = 20
var gold = 0
var deck_count: int = 0
var deck_max: int = 42

var card_position = 0
var _initialized = false
var _game_over = false

# ---/ITEM STATE/---
var weapon = ""
var potion = ""
var true_weapon = null
var true_potion = null

# ---/ARRAY VARIABLES/---
var deck: Array = []
var deck_symbols: Array = []

var room: Array = []
var room_symbols: Array = []

var items: Array = [true_weapon, true_potion]
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

func _emit_inventory() -> void:
	_emit_symbols()
	emit_signal("inventory_changed", weapon, potion)

func _emit_deck() -> void:
	emit_signal("send_deck", deck)

func _emit_room() -> void:
	_emit_symbols()
	_emit_inventory()
	emit_signal("room_updated", room_symbols, deck)

func _emit_stats() -> void:
	_emit_symbols()
	emit_signal("stats_changed", hp, max_hp, deck_count, deck_max, gold)

func _emit_game_over() -> void:
	_game_over = true
	emit_signal("game_over", _game_over)

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
		if true_weapon == null:
			weapon = null
			continue
			var card = key
			var symbol = card.id
			items_symbols.append(symbol)
		if true_potion == null:
			potion = null
			continue
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
			KEY_P:
				handle_command("heal")

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
	_say("▻THE DECK HAS BEEN SHUFFLED.\n\n")
	deck_count = deck.size()
	_emit_stats()
	fill_room()

func fill_room() -> void:
	while room.size() < 4:
		var card = deck[0]
		var position = card_position
		if _initialized == false:
			room.append(card)
		else:
			room.insert(position, card)
		deck.remove_at(0)
	card_position = 4
	_initialized = true
	_emit_stats()
	_emit_room()

func choose_card() -> void:
	var card = room[card_position]
	var symbol = str(card.id)
	var current_weapon = weapon
	var current_potion = potion
	
	if card.type == "enemy":
		attack(card, symbol)
	elif card.type == "weapon":
		if weapon != "":
			items.remove_at(0)
			discard.append(card)
			_say("▻DISCARDED WEAPON (" + current_weapon + ")\n\n")
		items.insert(0, card)
		weapon = symbol
		true_weapon = card
		_say("▻EQUIPPED WEAPON (" + symbol + ")\n\n")
	elif card.type == "potion":
		true_weapon = card
		if true_potion != null:
			items.remove_at(1)
			items.insert(1, card)
			discard.append(card)
			_say("▻DISCARDED POTION (" + current_potion + ")\n\n")
		else:
			items.insert(1, card)
			true_weapon = card
		potion = symbol
		_say("▻EQUIPPED POTION (" + symbol + ")\n\n")
	_emit_inventory()
	room.remove_at(card_position)
	fill_room()

func enter_room() -> void:
	generate_deck()

# ---/ACTIONS/---
func attack(enemy: Dictionary, symbol: String) -> void:
	var enemy_hp = enemy.value
	var old_hp = hp
	var weapon_dmg = 0
	
	if weapon != "":
		weapon_dmg = items[0].value
		
	var hit_dmg = max(enemy_hp - weapon_dmg, 0)
	hp = max(old_hp - hit_dmg, 0)
	if hp == 0:
		_emit_game_over()
	
	_emit_inventory()
	_say("▻DEFEATED ENEMY (" + symbol + ")\n\n")
	if weapon != "":
		_say("▻WEAPON (" + str(weapon) + ") WAS DESTROYED\n\n")
		items.remove_at(0)
		
	if hit_dmg == 0:
		_say("▻NO DAMAGE TAKEN\n\n")
	else:
		_say("▻(" + str(hit_dmg) + ") DAMAGE TAKEN\n\n")
	weapon = ""

func use_potion() -> void:
	var old_hp = hp
	var _potion = true_potion
	var heal_amount = 0
	if potion == "":
		_say("NO POTION IN INVENTORY\n\n")
		return
	var symbol = potion
	if _potion.value is not int:
		heal_amount = 0
	else:
		heal_amount = int(_potion.value)
	hp = max(old_hp + heal_amount, max_hp)
	true_potion = null
	_emit_inventory()
	_say("USED POTION (" + str(symbol) + ") - GAINED " + str(heal_amount) + " HP\n\n")
