extends Control

@onready var sprite = $Container/ImagePanel/Image
@onready var title = $Container/Panel/Name
@onready var textbox = $Container/Panel/Dialogue
@onready var choices = $Container/Panel/Choices

@export var active: NpcData

var index: int = 0
var chat = []
var ref

func _ready() -> void:
	active = Global.current_npc
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

	for item in choices.get_children():
		item.queue_free() 
		
	for choice_text in current_node["choices"]:
		var destination = current_node["choices"][choice_text]
	
		var button = Button.new()
		button.text = choice_text
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.custom_minimum_size.x = 250
		
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

func leave() -> void:
	Global.current_npc = null
	Pos.return_from(false, "res://minesweeper/board.tscn")
