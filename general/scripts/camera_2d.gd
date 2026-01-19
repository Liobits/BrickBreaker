# camera_controller.gd
extends Camera2D
class_name CameraController

@export var pan_speed := 1000.0

# Zoom settings
@export var zoom_step := 0.2
@export var min_zoom := 0.25
@export var max_zoom := 1.0
@export var zoom_smooth_speed := 5.0

var target_zoom := Vector2.ONE

func _ready():
	zoom = Vector2.ONE
	target_zoom = zoom

func _physics_process(delta):
	handle_pan(delta)
	handle_smooth_zoom(delta)

func handle_pan(delta):
	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	if input_vector != Vector2.ZERO:
		global_position += input_vector.normalized() * pan_speed * delta

func handle_smooth_zoom(delta):
	# Smoothly interpolate current zoom towards target_zoom
	zoom = zoom.lerp(target_zoom, zoom_smooth_speed * delta)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				zoom_out()
			MOUSE_BUTTON_WHEEL_DOWN:
				zoom_in()

func zoom_in():
	# Decrease zoom vector → objects appear bigger (closer)
	var new_zoom = target_zoom.x - zoom_step
	new_zoom = clamp(new_zoom, min_zoom, max_zoom)
	target_zoom = Vector2(new_zoom, new_zoom)

func zoom_out():
	# Increase zoom vector → objects appear smaller (further away)
	var new_zoom = target_zoom.x + zoom_step
	new_zoom = clamp(new_zoom, min_zoom, max_zoom)
	target_zoom = Vector2(new_zoom, new_zoom)
