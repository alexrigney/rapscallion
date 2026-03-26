extends Control
class_name Card

@onready var card_icon: TextureRect = %CardIcon
@onready var card_theme: Theme = preload("res://Themes/card_theme.tres")

const CARD_SHEET: CompressedTexture2D = preload("res://Card Icons/test/FantasyCards.png")

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

var atlas = AtlasTexture

func _ready() -> void:
	atlas = AtlasTexture.new()
	atlas.atlas = CARD_SHEET
	card_icon.texture = atlas


func set_card(card_data: Dictionary) -> void:
	var row: int = SUIT_ROW[card_data["suit"]]
	var col: int = RANK_COL[card_data["rank"]]
	
	var x: int = START_X + (col * (CARD_W + GAP_X))
	var y: int = START_Y + (row * (CARD_H + GAP_Y))
	
	if card_data != {}:
		atlas.region = Rect2(x, y, CARD_W, CARD_H)
	else:
		card_icon.texture = ResourceLoader.load("res://Card Icons/test/Card.png")
	
	card_icon.custom_minimum_size = Vector2(138, 210)
	card_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	card_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	card_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
	#card_icon.custom_minimum_size = Vector2(150, 220)
	#card_icon.theme = card_theme
	#card_icon.ignore_texture_size = true
	#card_icon.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT
	#
	#if card_data != {}:
		#card_icon.texture_normal = ResourceLoader.load("res://Card Icons/" + card_data.asset_id + ".png")
	#else:
		#card_icon.texture_normal = ResourceLoader.load("res://Card Icons/blank.png")
