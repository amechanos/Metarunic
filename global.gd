extends Node

const SAVE_PATH := "user://metarunic_save.dat"
const SAVE_VERSION := 1
const SETTINGS_PATH := "user://metarunic_settings.cfg"
const DEFAULT_MASTER_VOLUME := 1.0
const DEFAULT_DIALOGUE_TEXT_SPEED := 20.0
const MIN_DIALOGUE_TEXT_SPEED := 5.0
const MAX_DIALOGUE_TEXT_SPEED := 60.0
const PAUSE_MENU_SCRIPT = preload("res://ui/pause_menu.gd")

const MAX_HEALTH := 10
var health: int = MAX_HEALTH
var bard_heal_count: int = 0

# Minesweeper Mode 
const TILE_SIZE = 96
const WIDTH = 8
const HEIGHT = 6

var fade_duration = WIDTH
var grid: Array = []

var found: int = 0

# Jigsaw Mode
var shardLibrary: Dictionary = {}

var assemblyState: Dictionary = {}

var lostShards: Dictionary = {}
var foundShards: Dictionary = {}

var completedCards: Array = ["the_fool", "wheel_of_fortune"]

var music_player: AudioStreamPlayer

var saved_player_position := Vector2.ZERO
var pending_player_position := Vector2.ZERO
var has_pending_player_position := false
var last_save_error := ""
var master_volume: float = DEFAULT_MASTER_VOLUME
var dialogue_text_speed: float = DEFAULT_DIALOGUE_TEXT_SPEED

func _ready():
	Loader.load_shard_library()
	lostShards = shardLibrary
	load_settings()

func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel") or event.is_echo() or get_tree().paused:
		return

	var current_scene := get_tree().current_scene
	if current_scene == null or current_scene.scene_file_path == "res://mainmenu.tscn":
		return

	current_scene.add_child(PAUSE_MENU_SCRIPT.new())
	get_tree().paused = true
	get_viewport().set_input_as_handled()
	
# Environment
var current_npc: NpcData = null
var current_beast: BeastData = null
var defeated_beasts: Array[String] = []

func has_save_game() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func load_settings() -> void:
	var settings := ConfigFile.new()
	var error := settings.load(SETTINGS_PATH)
	if error != OK and error != ERR_FILE_NOT_FOUND:
		push_error("Could not load settings (error %d)." % error)
		return

	master_volume = clampf(
		float(settings.get_value("audio", "master_volume", DEFAULT_MASTER_VOLUME)),
		0.0,
		1.0
	)
	dialogue_text_speed = clampf(
		float(settings.get_value("dialogue", "text_speed", DEFAULT_DIALOGUE_TEXT_SPEED)),
		MIN_DIALOGUE_TEXT_SPEED,
		MAX_DIALOGUE_TEXT_SPEED
	)
	_apply_master_volume()

func set_master_volume(value: float) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	_apply_master_volume()
	_save_settings()

func set_dialogue_text_speed(value: float) -> void:
	dialogue_text_speed = clampf(value, MIN_DIALOGUE_TEXT_SPEED, MAX_DIALOGUE_TEXT_SPEED)
	_save_settings()

func _apply_master_volume() -> void:
	var master_bus := AudioServer.get_bus_index("Master")
	if master_bus == -1:
		push_error("The Master audio bus could not be found.")
		return
	AudioServer.set_bus_mute(master_bus, is_zero_approx(master_volume))
	if not is_zero_approx(master_volume):
		AudioServer.set_bus_volume_db(master_bus, linear_to_db(master_volume))

func _save_settings() -> void:
	var settings := ConfigFile.new()
	settings.set_value("audio", "master_volume", master_volume)
	settings.set_value("dialogue", "text_speed", dialogue_text_speed)
	var error := settings.save(SETTINGS_PATH)
	if error != OK:
		push_error("Could not save settings (error %d)." % error)

func start_new_game() -> void:
	health = MAX_HEALTH
	bard_heal_count = 0
	found = 0
	Loader.load_shard_library()
	lostShards = shardLibrary
	foundShards.clear()
	assemblyState.clear()
	completedCards = ["the_fool", "wheel_of_fortune"]
	defeated_beasts.clear()
	current_npc = null
	current_beast = null
	grid.clear()
	saved_player_position = Vector2(Global.TILE_SIZE / 2.0, Global.TILE_SIZE / 2.0)
	pending_player_position = Vector2.ZERO
	has_pending_player_position = false
	Pos.temp = Vector2.ZERO
	Pos.temp_i = Vector2i.ZERO
	Pos.return_spawn_tile = Vector2i(-1, -1)
	Pos.from_ui = false
	Pos.dir = ""
	Pos.entry_direction = ""
	Map.reset_world()

func save_game() -> bool:
	last_save_error = ""

	var current_scene := get_tree().current_scene
	if current_scene and current_scene.has_method("capture_state"):
		current_scene.call("capture_state")
	var board: Node = null
	if current_scene:
		board = current_scene.get_node_or_null("board")
	if board and board.has_method("capture_current_room") and not has_pending_player_position:
		board.call("capture_current_room")
		var player := board.get_node_or_null("player") as Node2D
		if player:
			saved_player_position = player.global_position
	elif has_pending_player_position:
		saved_player_position = pending_player_position

	var serialized_found_shards: Variant = _serialize_shard_groups(foundShards)
	var serialized_lost_shards: Variant = _serialize_shard_groups(lostShards)
	var serialized_rooms: Variant = _serialize_rooms(Map.map)
	if serialized_found_shards == null or serialized_lost_shards == null or serialized_rooms == null:
		last_save_error = "Game state contains data that cannot be saved."
		push_error(last_save_error)
		return false

	var map_nodes: Array[Dictionary] = []
	for map_node: MapCell in Map.map_nodes_array:
		map_nodes.append({
			"grid_position": map_node.grid_position,
			"path_left": map_node.path_left,
			"path_right": map_node.path_right,
			"path_top": map_node.path_top,
			"path_bottom": map_node.path_bottom
		})

	var save_data := {
		"version": SAVE_VERSION,
		"health": health,
		"bard_heal_count": bard_heal_count,
		"found": found,
		"found_shards": serialized_found_shards,
		"lost_shards": serialized_lost_shards,
		"completed_cards": completedCards.duplicate(),
		"assembly_state": assemblyState.duplicate(true),
		"defeated_beasts": defeated_beasts.duplicate(),
		"player_position": saved_player_position,
		"map": {
			"current_node": Map.current_node,
			"rooms": serialized_rooms,
			"map_nodes": map_nodes,
			"discovered_nodes": Map.discovered_nodes.duplicate(),
			"spawn_ref": Map.spawn_ref.duplicate(true),
			"beast_pool": Map.beast_pool.duplicate(),
			"npc_pool": Map.npc_pool.duplicate(),
			"map_width": Map.map_width,
			"map_height": Map.map_height
		}
	}

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		last_save_error = "Could not open save file for writing (error %d)." % FileAccess.get_open_error()
		push_error(last_save_error)
		return false

	file.store_var(save_data, false)
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		last_save_error = "Could not write save file (error %d)." % write_error
		push_error(last_save_error)
		return false

	return true

func load_game() -> bool:
	last_save_error = ""
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		last_save_error = "Could not open save file (error %d)." % FileAccess.get_open_error()
		push_error(last_save_error)
		return false

	var save_data: Variant = file.get_var(false)
	file.close()
	if not _is_valid_save(save_data):
		last_save_error = "The save file is invalid or incompatible."
		push_error(last_save_error)
		return false

	var map_data: Dictionary = save_data["map"]
	var serialized_found_shards: Variant = _deserialize_shard_groups(save_data["found_shards"])
	var serialized_lost_shards: Variant = _deserialize_shard_groups(save_data["lost_shards"])
	var serialized_rooms: Variant = _deserialize_rooms(map_data["rooms"])
	if serialized_found_shards == null or serialized_lost_shards == null or serialized_rooms == null:
		last_save_error = "The save file references missing or invalid game data."
		push_error(last_save_error)
		return false

	health = int(save_data["health"])
	bard_heal_count = int(save_data["bard_heal_count"])
	found = int(save_data["found"])
	foundShards = serialized_found_shards
	lostShards = serialized_lost_shards
	completedCards = save_data["completed_cards"].duplicate()
	assemblyState = save_data["assembly_state"].duplicate(true)
	defeated_beasts.assign(save_data["defeated_beasts"])
	current_npc = null
	current_beast = null

	Map.map_width = int(map_data["map_width"])
	Map.map_height = int(map_data["map_height"])
	Map.generate(Map.map_width, Map.map_height)
	for index in range(map_data["map_nodes"].size()):
		var node_data: Dictionary = map_data["map_nodes"][index]
		var map_node: MapCell = Map.map_nodes_array[index]
		map_node.grid_position = node_data["grid_position"]
		map_node.path_left = node_data["path_left"]
		map_node.path_right = node_data["path_right"]
		map_node.path_top = node_data["path_top"]
		map_node.path_bottom = node_data["path_bottom"]
	Map.current_node = int(map_data["current_node"])
	Map.map = serialized_rooms
	Map.discovered_nodes = map_data["discovered_nodes"].duplicate()
	Map.spawn_ref = map_data["spawn_ref"].duplicate(true)
	Map.beast_pool = map_data["beast_pool"].duplicate()
	Map.npc_pool = map_data["npc_pool"].duplicate()
	grid = Map.map.get(Map.current_node, {}).get("grid", [])

	saved_player_position = save_data["player_position"]
	pending_player_position = saved_player_position
	has_pending_player_position = true
	Pos.temp = Vector2.ZERO
	Pos.temp_i = Vector2i.ZERO
	Pos.return_spawn_tile = Vector2i(-1, -1)
	Pos.from_ui = false
	Pos.dir = ""
	Pos.entry_direction = ""
	return true

func _serialize_shard_groups(groups: Dictionary) -> Variant:
	var serialized: Dictionary = {}
	for card_name in groups:
		var serialized_shards: Array[Dictionary] = []
		for shard_value in groups[card_name]:
			var shard := shard_value as shardData
			if shard == null:
				return null
			serialized_shards.append({
				"polygon": shard.polygon,
				"uv": shard.uv,
				"correct_rotation": shard.correct_rotation.duplicate(),
				"grid_pos": shard.grid_pos,
				"piece_size": shard.piece_size,
				"is_edge": shard.is_edge,
				"centroid": shard.centroid,
				"card": shard.card
			})
		serialized[card_name] = serialized_shards
	return serialized

func _deserialize_shard_groups(groups: Variant) -> Variant:
	if typeof(groups) != TYPE_DICTIONARY:
		return null
	var deserialized: Dictionary = {}
	for card_name in groups:
		if typeof(groups[card_name]) != TYPE_ARRAY:
			return null
		var shards: Array[shardData] = []
		for shard_data in groups[card_name]:
			if typeof(shard_data) != TYPE_DICTIONARY:
				return null
			var shard := shardData.new()
			shard.polygon = PackedVector2Array(shard_data.get("polygon", PackedVector2Array()))
			shard.uv = PackedVector2Array(shard_data.get("uv", PackedVector2Array()))
			shard.correct_rotation.assign(shard_data.get("correct_rotation", []))
			shard.grid_pos = shard_data.get("grid_pos", Vector2i.ZERO)
			shard.piece_size = shard_data.get("piece_size", Vector2.ZERO)
			shard.is_edge = shard_data.get("is_edge", false)
			shard.centroid = shard_data.get("centroid", Vector2.ZERO)
			shard.card = shard_data.get("card", str(card_name))
			shards.append(shard)
		deserialized[card_name] = shards
	return deserialized

func _serialize_entities(entities: Array) -> Variant:
	var serialized: Array[Dictionary] = []
	for entity in entities:
		if typeof(entity) != TYPE_DICTIONARY:
			return null
		var data := entity.get("data") as Resource
		if data == null or data.resource_path.is_empty():
			return null
		serialized.append({
			"resource_path": data.resource_path,
			"position": entity.get("position", Vector2i.ZERO),
			"direction": entity.get("direction", "NORTH")
		})
	return serialized

func _deserialize_entities(entities: Variant) -> Variant:
	if typeof(entities) != TYPE_ARRAY:
		return null
	var deserialized: Array[Dictionary] = []
	for entity in entities:
		if typeof(entity) != TYPE_DICTIONARY:
			return null
		var resource_path: String = entity.get("resource_path", "")
		if resource_path.is_empty() or not ResourceLoader.exists(resource_path):
			return null
		var resource := ResourceLoader.load(resource_path)
		if resource == null:
			return null
		deserialized.append({
			"data": resource,
			"position": entity.get("position", Vector2i.ZERO),
			"direction": entity.get("direction", "NORTH")
		})
	return deserialized

func _serialize_rooms(rooms: Dictionary) -> Variant:
	var serialized: Dictionary = {}
	for room_id in rooms:
		var room: Dictionary = rooms[room_id]
		var room_data: Dictionary = {}
		for field in ["width", "height", "shards", "found", "flagged_tiles", "revealed_tiles", "restricted_tiles", "nav_tiles", "grid"]:
			if room.has(field):
				room_data[field] = room[field]
		var beasts: Variant = _serialize_entities(room.get("beasts", []))
		var npcs: Variant = _serialize_entities(room.get("npcs", []))
		if beasts == null or npcs == null:
			return null
		room_data["beasts"] = beasts
		room_data["npcs"] = npcs
		serialized[room_id] = room_data
	return serialized

func _deserialize_rooms(rooms: Variant) -> Variant:
	if typeof(rooms) != TYPE_DICTIONARY:
		return null
	var deserialized: Dictionary = {}
	for room_id in rooms:
		if typeof(rooms[room_id]) != TYPE_DICTIONARY:
			return null
		var room: Dictionary = rooms[room_id]
		for field in ["width", "height", "shards", "found", "flagged_tiles", "revealed_tiles", "restricted_tiles", "nav_tiles", "grid", "beasts", "npcs"]:
			if not room.has(field):
				return null
		if int(room["width"]) != WIDTH or int(room["height"]) != HEIGHT:
			return null
		if typeof(room["flagged_tiles"]) != TYPE_ARRAY or typeof(room["revealed_tiles"]) != TYPE_DICTIONARY:
			return null
		if typeof(room["restricted_tiles"]) != TYPE_ARRAY or typeof(room["nav_tiles"]) != TYPE_DICTIONARY:
			return null
		if typeof(room["grid"]) != TYPE_ARRAY or room["grid"].size() != WIDTH:
			return null
		for column in room["grid"]:
			if typeof(column) != TYPE_ARRAY or column.size() != HEIGHT:
				return null
		var room_data: Dictionary = room.duplicate(true)
		var beasts: Variant = _deserialize_entities(room.get("beasts", []))
		var npcs: Variant = _deserialize_entities(room.get("npcs", []))
		if beasts == null or npcs == null:
			return null
		room_data["beasts"] = beasts
		room_data["npcs"] = npcs
		deserialized[room_id] = room_data
	return deserialized

func _is_valid_save(save_data: Variant) -> bool:
	if typeof(save_data) != TYPE_DICTIONARY or save_data.get("version") != SAVE_VERSION:
		return false
	for field in ["health", "bard_heal_count", "found", "found_shards", "lost_shards", "completed_cards", "assembly_state", "defeated_beasts", "player_position", "map"]:
		if not save_data.has(field):
			return false
	if typeof(save_data["health"]) != TYPE_INT or typeof(save_data["bard_heal_count"]) != TYPE_INT or typeof(save_data["found"]) != TYPE_INT:
		return false
	if typeof(save_data["completed_cards"]) != TYPE_ARRAY or typeof(save_data["assembly_state"]) != TYPE_DICTIONARY:
		return false
	if typeof(save_data["defeated_beasts"]) != TYPE_ARRAY or typeof(save_data["player_position"]) != TYPE_VECTOR2:
		return false
	var map_data: Variant = save_data["map"]
	if typeof(map_data) != TYPE_DICTIONARY:
		return false
	for field in ["current_node", "rooms", "map_nodes", "discovered_nodes", "spawn_ref", "beast_pool", "npc_pool", "map_width", "map_height"]:
		if not map_data.has(field):
			return false
	if typeof(map_data["map_width"]) != TYPE_INT or typeof(map_data["map_height"]) != TYPE_INT:
		return false
	if int(map_data["map_width"]) <= 0 or int(map_data["map_height"]) <= 0:
		return false
	if typeof(map_data["current_node"]) != TYPE_INT or int(map_data["current_node"]) < 1:
		return false
	if typeof(map_data["map_nodes"]) != TYPE_ARRAY or map_data["map_nodes"].size() != int(map_data["map_width"]) * int(map_data["map_height"]):
		return false
	if int(map_data["current_node"]) > map_data["map_nodes"].size():
		return false
	if typeof(map_data["rooms"]) != TYPE_DICTIONARY or typeof(map_data["discovered_nodes"]) != TYPE_ARRAY:
		return false
	if typeof(map_data["spawn_ref"]) != TYPE_DICTIONARY or typeof(map_data["beast_pool"]) != TYPE_ARRAY or typeof(map_data["npc_pool"]) != TYPE_ARRAY:
		return false
	for node_data in map_data["map_nodes"]:
		if typeof(node_data) != TYPE_DICTIONARY:
			return false
		for field in ["grid_position", "path_left", "path_right", "path_top", "path_bottom"]:
			if not node_data.has(field):
				return false
		if typeof(node_data["grid_position"]) != TYPE_VECTOR2:
			return false
		for field in ["path_left", "path_right", "path_top", "path_bottom"]:
			if typeof(node_data[field]) != TYPE_BOOL:
				return false
	return true
