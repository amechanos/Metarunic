extends Node

var temp: Vector2
var temp_i: Vector2i
var return_spawn_tile: Vector2i = Vector2i(-1, -1)

var from_ui = false
var dir: String
var entry_direction: String = ""

func move(coords: Vector2, destination: String, spawn_tile: Vector2i = Vector2i(-1, -1)):
	temp = coords
	return_spawn_tile = spawn_tile
	get_tree().change_scene_to_file(destination)
	from_ui = true

func set_player(step, player) -> void:
	if from_ui:
		player.global_position = temp
		from_ui = false
		temp = Vector2.ZERO
		return

	var vectorised = Vector2(temp_i.x * step + step / 2, temp_i.y * step + step / 2)
	player.global_position = vectorised

func on_new_board(tile: Vector2i, dir: String, height, width) -> Vector2i:
	
	match dir:
		"NORTH":
			return Vector2i(tile.x, height-1)
		"SOUTH":
			return Vector2i(tile.x, 0)
		"EAST":
			return Vector2i(0, tile.y)
		"WEST":
			return Vector2i(width-1, tile.y)
		"UP":
			return Vector2i(tile.x, height-1)
		"DOWN":
			return Vector2i(tile.x, 0)
		"RIGHT":
			return Vector2i(0, tile.y)
		"LEFT":
			return Vector2i(width-1, tile.y)
	
	print("Couldn't find relevant direction! Defaulting temp to (0,0)")
	return Vector2i.ZERO

func return_from(affected: bool, destination: String):
	var relative = _tile_from_position(temp)
	if affected:
		var spawn_tile = return_spawn_tile if return_spawn_tile != Vector2i(-1, -1) else find_spawn_tile(relative)
	
		Map.map[Map.current_node]["beasts"] = Map.map[Map.current_node]["beasts"].filter(
			func(beast): return beast["position"] != spawn_tile
		)
		return_spawn_tile = Vector2i(-1, -1)
	
	print("Returning player to: ", temp)
	get_tree().change_scene_to_file(destination)

func _tile_from_position(position: Vector2) -> Vector2i:
	return Vector2i(
		round((position.x - Global.TILE_SIZE / 2.0) / Global.TILE_SIZE),
		round((position.y - Global.TILE_SIZE / 2.0) / Global.TILE_SIZE)
	)
		
func find_spawn_tile(tile: Vector2) -> Vector2i:
	var tile_i = Vector2i(tile)
	
	if tile_i.y == 0:
		return tile_i + Vector2i(0, -1)
	elif tile_i.y == Global.HEIGHT - 1:
		return tile_i + Vector2i(0, 1)
	elif tile_i.x == 0:
		return tile_i + Vector2i(-1, 0)
	elif tile_i.x == Global.WIDTH - 1:
		return tile_i + Vector2i(1, 0)

	return Vector2i.ZERO
