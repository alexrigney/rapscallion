extends Control
class_name Card

@onready var card_theme: Theme = preload("res://Themes/card_theme.tres")
@onready var state: GameState = $GameState

func draw_card(card: Dictionary) -> void:
	
	var c = Button.new()
	c.custom_minimum_size = Vector2(190, 270)
	c.theme = card_theme
	
	if card != {}:
		c.text = card.id
		match card.type:
			"enemy":
				c.add_theme_color_override(
				"font_color", Color(0.081, 0.081, 0.081, 1.0))
			_:
				c.add_theme_color_override(
				"font_color", Color(0.706, 0.067, 0.188, 1.0))
	else:
		c.text = ""
