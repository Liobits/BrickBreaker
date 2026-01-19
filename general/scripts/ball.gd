extends Node2D
class_name Ball

@export var speed := 600.0
@export var damage := 1
@export var max_bounces := 5

var direction := Vector2.UP
var bounce_count := 0


func _physics_process(delta: float) -> void:
	if not World.collision:
		return

	var motion := direction * speed * delta
	var result := World.collision.sweep_circle(global_position, motion)

	if result.hit:
		global_position = result.position

		World.data.damage_brick(result.grid.x, result.grid.y, damage)

		direction = direction.bounce(result.normal).normalized()
		bounce_count += 1

		if max_bounces >= 0 and bounce_count >= max_bounces:
			queue_free()
	else:
		global_position += motion
