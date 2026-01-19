extends Node
class_name WorldData

# Chunk size in grid cells
const CHUNK_WIDTH := 32
const CHUNK_HEIGHT := 32

# Dictionary of chunks
# key: Vector2i(chunk_x, chunk_y)
# value: Dictionary of local brick data
var chunks := {}

@warning_ignore_start("integer_division")

@onready var world_collision: WorldCollision = $"../WorldCollision"

func _ready() -> void:
	world_collision.setup(self)

func _chunk_key(grid_x: int, grid_y: int) -> Vector2i:

	return Vector2i(
		floori(grid_x / CHUNK_WIDTH),
		floori(grid_y / CHUNK_HEIGHT)
	)

func _local_key(grid_x: int, grid_y: int) -> Vector2i:
	return Vector2i(
		posmod(grid_x, CHUNK_WIDTH),
		posmod(grid_y, CHUNK_HEIGHT)
	)

func ensure_brick(grid_x: int, grid_y: int):
	var ckey := _chunk_key(grid_x, grid_y)
	var lkey := _local_key(grid_x, grid_y)

	if not chunks.has(ckey):
		chunks[ckey] = {}

	if not chunks[ckey].has(lkey):
		chunks[ckey][lkey] = {
			"hp": 3
		}

func has_brick(grid_x: int, grid_y: int) -> bool:
	var ckey := _chunk_key(grid_x, grid_y)
	var lkey := _local_key(grid_x, grid_y)

	return chunks.has(ckey) and chunks[ckey].has(lkey)

func damage_brick(grid_x: int, grid_y: int, dmg: int):
	if not has_brick(grid_x, grid_y):
		return

	var ckey := _chunk_key(grid_x, grid_y)
	var lkey := _local_key(grid_x, grid_y)

	chunks[ckey][lkey]["hp"] -= dmg
	if chunks[ckey][lkey]["hp"] <= 0:
		chunks[ckey].erase(lkey)

func get_chunk(chunk_key: Vector2i) -> Dictionary:
	if not chunks.has(chunk_key):
		chunks[chunk_key] = {}
	return chunks[chunk_key]

func get_brick_at(grid: Vector2i):
	var chunk_x := floori(grid.x / CHUNK_WIDTH)
	var chunk_y := floori(grid.y / CHUNK_HEIGHT)
	var chunk_key := Vector2i(chunk_x, chunk_y)

	if not chunks.has(chunk_key):
		return null

	var local_x := grid.x - chunk_x * CHUNK_WIDTH
	var local_y := grid.y - chunk_y * CHUNK_HEIGHT
	var local_key := Vector2i(local_x, local_y)

	var chunk = chunks[chunk_key]

	if not chunk.has(local_key):
		return null

	return chunk[local_key] # BrickData (contains hp)
