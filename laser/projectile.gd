extends Area2D


export var direction:Vector2 = Vector2.LEFT
export var speed:float = 10.0
export var accel:float = 1.04
var team:int
var damage = 10

onready var laser_hit = load("res://laser/laser_hit/laser_hit.tscn")

func _physics_process(delta:float):
	speed *= accel
	translate(direction*speed)
	calculate_rotation()

func calculate_rotation() -> void:
	rotation_degrees = rad2deg(direction.angle() + PI/2)

func _on_Timer_timeout():
	queue_free()

func _on_body_entered(body):
	if(body.is_in_group("ship") && body.team != team):
		body.damage(damage)
		
		var instance = laser_hit.instance()
		instance.position = position + scale.y * 0.5 * direction
		instance.process_material.direction = Vector3(direction.x, direction.y, 0)
		instance.process_material.initial_velocity = speed  * 3
		instance.restart()
		get_tree().current_scene.add_child(instance)
		
		queue_free()
