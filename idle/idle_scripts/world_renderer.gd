extends Node2D
class_name WorldRenderer

@export var brick_scene: PackedScene
@export var brick_size := Vector2(32, 16)
@export var start_y := 400
@export var view_margin := 2 # chunks

@onready var world_data: WorldData = get_node("../WorldData")
@onready var camera := get_viewport().get_camera_2d()

# Active visual chunks
var active_chunks := {}
var brick_nodes := {} 


func _ready() -> void:
	seed_wall()
	camera = get_viewport().get_camera_2d()
	call_deferred("update_visible_chunks")
	SignalBus.brick_removed.connect(_on_brick_removed)


func _process(_delta):
	update_visible_chunks()

func update_visible_chunks():
	if not camera:
		return

	var screen_rect := get_viewport_rect()

	var top_left := camera.global_position - screen_rect.size * 0.5 * camera.zoom
	var rect := Rect2(
		top_left,
		screen_rect.size * camera.zoom
	)

	var min_grid_x = floori(rect.position.x / brick_size.x)
	var max_grid_x = ceil(rect.end.x / brick_size.x)

	var min_grid_y = floori((start_y - rect.end.y) / brick_size.y)
	var max_grid_y = ceil((start_y - rect.position.y) / brick_size.y)

	# World top clamp
	min_grid_y = max(min_grid_y, 0)
	max_grid_y = max(max_grid_y, 0)

	var min_chunk := Vector2i(
		floori(min_grid_x / WorldData.CHUNK_WIDTH) - view_margin,
		floori(min_grid_y / WorldData.CHUNK_HEIGHT) - view_margin
	)
	var max_chunk := Vector2i(
		floori(max_grid_x / WorldData.CHUNK_WIDTH) + view_margin,
		floori(max_grid_y / WorldData.CHUNK_HEIGHT) + view_margin
	)

	var needed := {}

	for cy in range(min_chunk.y, max_chunk.y + 1):
		for cx in range(min_chunk.x, max_chunk.x + 1):
			var ckey := Vector2i(cx, cy)
			needed[ckey] = true
			if not active_chunks.has(ckey):
				spawn_chunk(ckey)

	# Remove unused chunks
	for ckey in active_chunks.keys():
		if not needed.has(ckey):
			clear_chunk(ckey)

func spawn_chunk(chunk_key: Vector2i):
	var container := Node2D.new()
	container.name = str(chunk_key)
	add_child(container)
	active_chunks[chunk_key] = container

	var chunk := world_data.get_chunk(chunk_key)

	for ly in WorldData.CHUNK_HEIGHT:
		for lx in WorldData.CHUNK_WIDTH:
			var lkey := Vector2i(lx, ly)
			if not chunk.has(lkey):
				continue

			var gx := chunk_key.x * WorldData.CHUNK_WIDTH + lx
			var gy := chunk_key.y * WorldData.CHUNK_HEIGHT + ly

			if gy < 0:
				continue

			var grid := Vector2i(gx, gy)
			
			var brick := brick_scene.instantiate()
			brick.position = Vector2(
				gx * brick_size.x + brick_size.x * 0.5,
				start_y - (gy + 1) * brick_size.y + brick_size.y * 0.5
			)
			container.add_child(brick)
			brick_nodes[grid] = brick


func clear_chunk(chunk_key: Vector2i):
	active_chunks[chunk_key].queue_free()
	active_chunks.erase(chunk_key)

func seed_wall(rows := 50, columns := 100):
	for y in rows:
		for x in columns:
			world_data.ensure_brick(x, y)
	

func _on_brick_removed(grid: Vector2i) -> void:
	if not brick_nodes.has(grid):
		return

	var brick = brick_nodes[grid]
	brick.queue_free()
	brick_nodes.erase(grid)
