extends Control

signal closed

@onready var volume = $Panel/VBoxContainer/Volume_labels/Step
@onready var speed = $Panel/VBoxContainer/Speed_labels/Step

@onready var volume_slider = $Panel/VBoxContainer/Volume
@onready var speed_slider = $Panel/VBoxContainer/Speed

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = 200
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	
	
	#var volume = get_node("Panel/VBoxContainer/Volume_labels/Step")
	#var speed = get_node("Panel/VBoxContainer/Speed_labels/Step")
	
	print(volume)
	
	volume.text = "%d%%" % roundi(volume_slider.value * 100.0)
	speed.text = "%d" % roundi(speed_slider.value)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_close()
		get_viewport().set_input_as_handled()

func _close() -> void:
	closed.emit()
	queue_free()

func _on_volume_value_changed(value: float) -> void:
	Global.set_master_volume(value)
	volume.text = "%d%%" % roundi(value * 100.0)

func _on_speed_value_changed(value: float) -> void:
	Global.set_dialogue_text_speed(value)
	speed.text = "%d" % roundi(value)
