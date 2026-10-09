extends Control

@onready var sprite = $Container/ImagePanel/Image
@onready var title = $Container/Panel/Name
@onready var textbox = $Container/Panel/Dialogue
@onready var choices = $Container/Panel/Choices
@onready var text_sound = $AudioStreamPlayer

@export var active: NpcData

@export_group("Text Settings")
@export var text_pitch: float = 1.5

var can_animate = false
var text_update: float = 0

var index: int = 0
var chat = []
var ref

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
	active = active if not Global.current_npc else Global.current_npc
	if active and active.logic_script != null:
		ref = active.logic_script.new()
		chat = ref.chat
		_setup_npc_visuals()

func _setup_npc_visuals() -> void:
	title.text = active.name
	textbox.text = chat[index]["text"]
	sprite.texture = active.texture
	update_dialogue()
		
# Call this function to initialize the dialogue when the interaction starts
func update_dialogue():
	var current_node = chat[index]
	var choice_count = current_node["choices"].size()
	choices.columns = 2 if choice_count > 4 else 1

	for item in choices.get_children():
		item.queue_free() 
		
	for choice_text in current_node["choices"]:
		var destination = current_node["choices"][choice_text]
	
		var button = Button.new()
		button.text = choice_text
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.custom_minimum_size = Vector2(0, 48)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 20)
		
		button.pressed.connect(func(): _on_choice_selected(destination))
		
		choices.add_child(button)
		
	if current_node["choices"].is_empty():
		await get_tree().create_timer(3).timeout
		leave()
		return

func _on_choice_selected(destination):
	if destination is int:
		index = destination
	elif destination is Callable:
		index = destination.call()
	
	textbox.text = ref.chat[index]["text"]
	print("Set index to ", index, " - Found text: ", textbox.text)
	update_dialogue()
	animate_text()

func leave() -> void:
	Global.current_npc = null
	Pos.return_from(false, "res://game.tscn")
