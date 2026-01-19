extends Node2D
class_name IdleBrickWall

@export var brick_scene: PackedScene

# Layout config
@export var brick_size := Vector2(32, 16)
@export var screen_size := Vector2(300, 648)
@export var start_y := 400

@export var max_rows := 3000


func _ready():
	generate_wall()

func generate_wall():
	clear_wall()


	var columns := int(ceil(screen_size.x / brick_size.x)) + 2

	for row in max_rows:
		var y := start_y - row * brick_size.y
		var x_offset := (row % 2) * (brick_size.x * 0.5)

		for col in columns:
			var x := col * brick_size.x - brick_size.x + x_offset

			var brick := brick_scene.instantiate()
			brick.position = Vector2(x, y)
			self.add_child(brick)

func clear_wall():
	for child in self.get_children():
		child.queue_free()
