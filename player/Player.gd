extends "res://fighter/Fighter.gd"

func _process(delta:float) -> void:
	if(Input.is_action_pressed("left_click") and mouse_pos.distance_to(position) > 10):
#		acceleration = mouse_dir.normalized() * speed
		thrust(mouse_pos-position, speed)
		accelerating = true
	else:
		acceleration = Vector2.ZERO
		accelerating = false

	if(Input.is_action_pressed("right_click")):
		fire_laser()

func _physics_process(delta:float) -> void:	
	facing = mouse_dir
	turn_to(mouse_dir)
