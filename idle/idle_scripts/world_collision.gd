extends Node
class_name WorldCollision

@export var brick_size := Vector2(32, 16)
@export var ball_radius := 8.0
@export var start_y := 400

func _ready():
	World.collision = self

func _broadphase(p0: Vector2, p1: Vector2) -> Array[Vector2i]:
	var r := ball_radius

	var min_x : float = min(p0.x, p1.x) - r
	var max_x : float = max(p0.x, p1.x) + r
	var min_y : float = min(p0.y, p1.y) - r
	var max_y : float = max(p0.y, p1.y) + r

	var gx0 := floori(min_x / brick_size.x)
	var gx1 := floori(max_x / brick_size.x)

	var gy0 := floori((start_y - max_y) / brick_size.y)
	var gy1 := floori((start_y - min_y) / brick_size.y)

	var result: Array[Vector2i] = []

	for gy in range(max(gy0, 0), max(gy1, 0) + 1):
		for gx in range(gx0, gx1 + 1):
			result.append(Vector2i(gx, gy))

	return result


func _swept_aabb(
	ball_pos: Vector2,
	velocity: Vector2,
	brick_min: Vector2,
	brick_max: Vector2
) -> Dictionary:
	var r := ball_radius

	var ball_min := ball_pos - Vector2(r, r)
	var ball_max := ball_pos + Vector2(r, r)

	var tx_entry: float
	var tx_exit: float
	var ty_entry: float
	var ty_exit: float

	if velocity.x > 0:
		tx_entry = (brick_min.x - ball_max.x) / velocity.x
		tx_exit  = (brick_max.x - ball_min.x) / velocity.x
	elif velocity.x < 0:
		tx_entry = (brick_max.x - ball_min.x) / velocity.x
		tx_exit  = (brick_min.x - ball_max.x) / velocity.x
	else:
		tx_entry = -INF
		tx_exit  = INF

	if velocity.y > 0:
		ty_entry = (brick_min.y - ball_max.y) / velocity.y
		ty_exit  = (brick_max.y - ball_min.y) / velocity.y
	elif velocity.y < 0:
		ty_entry = (brick_max.y - ball_min.y) / velocity.y
		ty_exit  = (brick_min.y - ball_max.y) / velocity.y
	else:
		ty_entry = -INF
		ty_exit  = INF

	var t_entry : float = max(tx_entry, ty_entry)
	var t_exit  : float = min(tx_exit, ty_exit)

	if t_entry > t_exit or t_entry < 0.0 or t_entry > 1.0:
		return { "hit": false }

	var normal := Vector2.ZERO
	if tx_entry > ty_entry:
		normal.x = -sign(velocity.x)
	else:
		normal.y = -sign(velocity.y)

	return {
		"hit": true,
		"t": t_entry,
		"normal": normal
	}

func sweep_ball(p0: Vector2, motion: Vector2) -> Dictionary:
	var p1 := p0 + motion
	var best_t := 1.0
	var best_hit : Dictionary = {}

	for grid in _broadphase(p0, p1):
		if not World.data.has_brick(grid.x, grid.y):
			continue

		var brick_min := Vector2(
			grid.x * brick_size.x,
			start_y - (grid.y + 1) * brick_size.y
		)
		var brick_max := brick_min + brick_size

		var hit := _swept_aabb(p0, motion, brick_min, brick_max)
		if hit.hit and hit.t < best_t:
			best_t = hit.t
			best_hit = {
				"grid": grid,
				"normal": hit.normal
			}

	if best_hit.is_empty():
		return { "hit": false }

	return {
		"hit": true,
		"position": p0 + motion * best_t,
		"normal": best_hit.normal,
		"grid": best_hit.grid
	}
