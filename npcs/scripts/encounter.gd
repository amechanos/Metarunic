extends Control

@onready var sprite = $Image
@onready var title = $Name
@onready var textbox = $Dialogue
@onready var choices = $Choices

@export var active: NpcData

var index: int = 0
var chat = []

func _ready() -> void:
	#active = Global.current_npc
	
	if active:
		print(Data.data)
		chat = Data.data.get(active.id)
		_setup_npc_visuals()

func _setup_npc_visuals() -> void:
	title.text = active.name
	textbox.text = chat[index]["text"]
	var dir_path = "res://npcs/textures/%s/SOUTH.png" % active.id
	set_choices()
	if ResourceLoader.exists(dir_path):
		sprite.texture = load(dir_path)
		
func set_choices():
	for item in choices.get_children():
		item.queue_free()
		
	# Spawn choice buttons	
	if chat[index]["choices"].is_empty():
		textbox.text = chat[index]["text"]
		await get_tree().create_timer(3).timeout
		leave()
		
	for item in chat[index]["choices"]:
		var destination = chat[index]["choices"][item]
	
		var button = Button.new()
		button.text = item
		button.custom_minimum_size.x = 450
		button.pressed.connect(func(): _on_choice_selected(destination))
		
		choices.add_child(button)

func _on_choice_selected(destination):
	index = destination
	textbox.text = chat[index]["text"]
	print("Set index to ", index, " - Found text: ", chat[index]["text"])
	set_choices()

func leave() -> void:
	Global.current_npc = null
	Pos.return_from(false, "res://minesweeper/board.tscn")
