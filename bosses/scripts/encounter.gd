extends Control

@onready var container = $Holder/CardDisplay
@onready var warning = $Warning
@onready var sprite = $Image
@onready var title = $Name
@onready var textbox = $Dialogue
@onready var next = $Next
@onready var text_sound = $AudioStreamPlayer

@export var active: Resource # The active beast or NPC

@export_group("Text Settings")
@export var text_pitch: float = 1.5

var can_animate = false
var text_update: float = 0

var target_text = ""
var time_since_last_update = 0

var beast_default = load("res://bosses/textures/SOUTH.png")
var scene

var riddle: String
var index: int = 0
var affected: bool = false

var dialogue: Array = []

func set_dialogue():
	dialogue = [
		"You approach the weathered statue and gently dust of the debris around.",
		"Removing the debris, you find some symbols near the base.",
		"You recognise the symbols forming a riddle and it reads: ",
		riddle,
		"You notice a small slit near the top, perhaps giving the statue an offering may awaken it?"
	]
	
	title.text = "???"
	textbox.text = dialogue[index]
	index += 1

func animate_text():
	text_sound.pitch_scale = text_pitch
	textbox.visible_characters = 0
	text_update = 0
	can_animate = true
	print("Text reset, animating...")

func _process(delta: float) -> void:
	if can_animate:
		text_update += delta * Global.dialogue_text_speed
		while text_update >= 1.0 and can_animate:
			text_update -= 1.0
			if textbox.visible_ratio < 1.0:
				var current_char = textbox.text[textbox.visible_characters]
				textbox.visible_characters += 1
				if current_char != " ":
					text_sound.play()

			# Stop animation if complete
			if textbox.visible_ratio >= 1.0:
				_finish_text()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and can_animate:
		_finish_text()

func _finish_text() -> void:
	textbox.visible_characters = -1
	can_animate = false
	text_sound.stop() # Explicitly cut off any lingering audio

func _ready() -> void:
	animate_text()
	next.show()
	active = active if not Global.current_beast else Global.current_beast

	affected = false
	riddle = active.riddle

	scene = get_tree().current_scene
	sprite.texture = beast_default
	setup()
	set_dialogue()

func setup():
	for card in Global.completedCards:
		print(card)
		var tarot = preload("res://ui/card.tscn").instantiate()
		var path = "res://tarot/cards/" + card + ".png"
		tarot.id = card
		tarot.custom_minimum_size = Vector2(196, 75)
		tarot.texture = load(path)
		container.add_child(tarot)
		tarot.connect("sent", giveCard)
	
	if container.get_children().is_empty():
		warning.visible = true
		
func giveCard(card: String, reversed: bool):
	next.visible = false
	if card.to_lower() == active.correct_card:
		textbox.text = active.upright_outcome if not reversed else active.reversed_outcome
		affected = true
		if active.id not in Global.defeated_beasts:
			Global.defeated_beasts.append(active.id)
	else:
		textbox.text = active.rejection_hint
		await get_tree().create_timer(5).timeout
		if scene == get_tree().current_scene:
			textbox.text = active.riddle_texts[Global.riddle_ref[active.id]]

func _on_leave_pressed() -> void:
	Global.current_beast = null
	Pos.return_from(affected, "res://game.tscn")

func _on_next_pressed() -> void:
	if index >= dialogue.size():
		index = 3
		textbox.text = dialogue[index]
		index += 1
		next.text = "Next"
		animate_text()
		return

	textbox.text = dialogue[index]
	animate_text()
	index += 1

	if index >= dialogue.size():
		animate_text()
		next.text = "view riddle"
