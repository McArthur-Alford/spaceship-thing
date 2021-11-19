extends Particles2D

var velocity:Vector2 = Vector2()
var magnitude:int
onready var explosion = load("res://explosion/explosion.tscn")

func initialize(pos:Vector2, vel:Vector2, mag:int):
	magnitude = mag
	position = pos
	velocity = vel.normalized() * 1
	emitting = true
	$Smoke.restart()
	$Lightning.restart()

func _process(delta):
	if(emitting == false):
		$Deletion.start()
	
	if(magnitude <= 0):
		$"Sub-Explosion".emitting = true
		$"Sub-Explosion/Lifetime".stop()
	velocity *= 0.999
	position += velocity

func _on_subexplosion():
	print(magnitude)
	
	magnitude -= 1
	
#	Split:
	var instance = explosion.instance()
	var perpendicular_velocity = Vector2(velocity.y, (rand_range(-1,1)) * velocity.x)
	instance.initialize(position,perpendicular_velocity * rand_range(-0.4,0.6) + velocity, magnitude - 1)
	get_tree().current_scene.add_child(instance)

#	Regen Self:
	instance = explosion.instance()
	instance.initialize(position,velocity, magnitude - 1)
	get_tree().current_scene.add_child(instance)


func _on_Deletion_timeout():
	queue_free()
