extends Control
class_name Card

@onready var card_icon: TextureButton = %CardIcon
@onready var card_theme: Theme = preload("res://Themes/card_theme.tres")


func set_card(card_data: Dictionary) -> void:
	
	card_icon.custom_minimum_size = Vector2(210, 300)
	card_icon.theme = card_theme
	card_icon.ignore_texture_size = true
	card_icon.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT
	
	if card_data != {}:
		card_icon.texture_normal = ResourceLoader.load("res://Card Icons/" + card_data.asset_id + ".png")
	else:
		card_icon.texture_normal = ResourceLoader.load("res://Card Icons/blank.png")
