extends Control
class_name Card

@onready var card_icon: TextureButton = %CardIcon
@onready var card_theme: Theme = preload("res://Themes/card_theme.tres")

const CARD_SHEET: CompressedTexture2D = preload("res://Card Icons/test/FantasyCards.png")

const SPADES = "♠"
const CLUBS = "♣"
const DIAMONDS = "♦"
const HEARTS = "♥"

const SUIT_ROW := {
	HEARTS: 0,
	DIAMONDS: 1,
	CLUBS: 2,
	SPADES: 3
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

func set_card(card_data: Dictionary) -> void:
	var row = SUIT_ROW[card_data.suit]
	var col = RANK_COL[card_data.rank]
	
	card_icon.custom_minimum_size = Vector2(150, 220)
	card_icon.theme = card_theme
	card_icon.ignore_texture_size = true
	card_icon.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT
	
	if card_data != {}:
		card_icon.texture_normal = ResourceLoader.load("res://Card Icons/" + card_data.asset_id + ".png")
	else:
		card_icon.texture_normal = ResourceLoader.load("res://Card Icons/blank.png")
