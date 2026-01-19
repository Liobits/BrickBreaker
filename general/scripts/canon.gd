extends Node2D


@export var ball_scene : PackedScene
@export var shoot_direction := Vector2.UP

@onready var ball_release_point: Marker2D = $CanonBody/BallReleasePoint
@onready var canon_body: Sprite2D = $CanonBody
@onready var shooting_timer: Timer = $ShootingTimer

var shooting_speed : float = 1

func _ready() -> void:
	shooting_timer.wait_time = shooting_speed
	shooting_timer.timeout.connect(_shoot)
	shooting_timer.start()
	$CanonBody.rotation = shoot_direction.angle()

func _shoot() -> void:
	var ball = ball_scene.instantiate()
	ball.direction = shoot_direction
	ball.global_position = ball_release_point.global_position
	ball.velocity = shoot_direction.normalized() * shooting_speed
	get_tree().current_scene.add_child(ball)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		shoot_direction = (get_global_mouse_position() - global_position).normalized()
		$CanonBody.rotation =  shoot_direction.angle()
