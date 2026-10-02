extends TileMapLayer

const TEXTURE_CHANCE := 0.1

var tiles: Dictionary = {
	"savanna": [
		Vector2i(0, 12),
		Vector2i(1, 12),
		Vector2i(2, 12),
		Vector2i(3, 12),
		Vector2i(4, 12)
	],
	"desert": [
		Vector2i(0, 5),
		Vector2i(1, 5),
		Vector2i(2, 5),
		Vector2i(3, 5),
		Vector2i(4, 5)
	],
	"snow": [
		Vector2i(0, 19),
		Vector2i(1, 19),
		Vector2i(2, 19),
		Vector2i(3, 19),
		Vector2i(4, 19)
	],
	"marsh": [
		Vector2i(11, 19),
		Vector2i(12, 19),
		Vector2i(13, 19),
		Vector2i(14, 19),
		Vector2i(15, 19)
	],
	"plains": [
		Vector2i(11, 12),
		Vector2i(12, 12),
		Vector2i(13, 12),
		Vector2i(14, 12),
		Vector2i(15, 12)
	],
	"cherry": [
		Vector2i(11, 5),
		Vector2i(12, 5),
		Vector2i(13, 5),
		Vector2i(14, 5),
		Vector2i(15, 5)
	],
}

func generate_background(biome: String, width: int, height: int) -> void:
	
	
	var biome_tiles: Array = tiles.get(biome, [])
	if biome_tiles.is_empty():
		push_warning("Unknown background biome: %s" % biome)
		return

	clear()
	for x in range(width):
		for y in range(height):
			var atlas_coords: Vector2i = biome_tiles[0]
			if biome_tiles.size() > 1 and randf() < TEXTURE_CHANCE:
				atlas_coords = biome_tiles[randi_range(1, biome_tiles.size() - 1)]
			set_cell(Vector2i(x, y), 0, atlas_coords)
