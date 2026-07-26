extends Resource

class_name NpcData

enum {NORTH, EAST, SOUTH, WEST}

@export var id: String = ""
@export var name: String = ""
@export var texture: Texture2D
@export var direction = NORTH

var is_npc = true
