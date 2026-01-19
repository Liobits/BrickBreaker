extends Node
class_name WorldCollision

@export var brick_size := Vector2(32, 16)
@export var ball_radius := 8.0

var world_data: WorldData


func setup(data: WorldData) -> void:
	world_data = data



func sweep_circle(start_pos: Vector2, motion: Vector2) -> Dictionary:
	if motion.length_squared() == 0.0:
		return { "hit": false }

	var dir := motion.normalized()
	var step := Vector2i(
		1 if dir.x > 0.0  else -1,
		1 if dir.y > 0.0  else -1
	)

	var grid := world_to_grid(start_pos)

	var t_delta := Vector2(
		abs(brick_size.x / motion.x) if motion.x != 0.0 else INF,
		abs(brick_size.y / motion.y) if motion.y != 0.0 else INF
	)

	var next_boundary := grid_to_world(grid)
	if step.x > 0: next_boundary.x += brick_size.x
	if step.y > 0: next_boundary.y += brick_size.y

	var t_max := Vector2(
		(next_boundary.x - start_pos.x) / motion.x if motion.x != 0.0 else INF,
		(next_boundary.y - start_pos.y) / motion.y if motion.y != 0.0 else INF
	)

	while true:
		if t_max.x < t_max.y:
			var t := t_max.x
			if t > 1.0: break
			grid.x += step.x
			t_max.x += t_delta.x
			if _brick_hit(grid):
				return _make_hit(start_pos, motion, t, Vector2(-step.x, 0), grid)
		else:
			var t := t_max.y
			if t > 1.0: break
			grid.y += step.y
			t_max.y += t_delta.y
			if _brick_hit(grid):
				return _make_hit(start_pos, motion, t, Vector2(0, -step.y), grid)

	return { "hit": false }



func _brick_hit(grid: Vector2i) -> bool:
	if not world_data:
		return false
	var brick = world_data.get_brick_at(grid)
	return brick != null and brick.hp > 0


func _make_hit(start: Vector2, motion: Vector2, t: float, normal: Vector2, grid: Vector2i) -> Dictionary:
	return {
		"hit": true,
		"position": start + motion * clampf(t, 0.0, 1.0),
		"normal": normal,
		"grid": grid
	}


func world_to_grid(pos: Vector2) -> Vector2i:
	return Vector2i(
		floor(pos.x / brick_size.x),
		floor(pos.y / brick_size.y)
	)


func grid_to_world(grid: Vector2i) -> Vector2:
	return Vector2(
		grid.x * brick_size.x,
		grid.y * brick_size.y
	)
