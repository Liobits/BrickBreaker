# brick.gd
extends StaticBody2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@export var max_hp := 1
var hp := 0
var collision_active : bool = false

func _ready():
	hp = max_hp
	collision_shape_2d.disabled =  !collision_active
	
	$Timer.start()

func take_damage(amount: int):
	hp -= amount
	if hp <= 0:
		queue_free()

func _on_timer_timeout() -> void:
	if !collision_shape_2d.disabled:
		modulate = 0xFFFF00FF
