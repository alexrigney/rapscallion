extends Control

@onready var text_log: RichTextLabel = %TextLog
@onready var state: GameState = $GameState

func _ready() -> void:
	state.log_text.connect(say)
	state.start_game()

func say(text: String) -> void:
	text_log.append_text(text)
