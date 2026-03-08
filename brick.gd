extends Sprite2D

func _process(_delta):
	queue_redraw()

func _draw():
	# 1. Calculate Global AABB (same as before)
	var rect = get_rect()
	var tf = global_transform
	var corners = [
		tf * rect.position,
		tf * Vector2(rect.end.x, rect.position.y),
		tf * rect.end,
		tf * Vector2(rect.position.x, rect.end.y)
	]

	var min_v = corners[0]
	var max_v = corners[0]
	for v in corners:
		min_v.x = min(min_v.x, v.x)
		min_v.y = min(min_v.y, v.y)
		max_v.x = max(max_v.x, v.x)
		max_v.y = max(max_v.y, v.y)

	# 2. THE FIX: "Undo" the sprite's transform for this specific drawing
	draw_set_transform_matrix(global_transform.affine_inverse())

	# 3. Draw using global coordinates
	var aabb_rect = Rect2(min_v, max_v - min_v)
	draw_rect(aabb_rect, Color.GREEN, false, 2.0)
