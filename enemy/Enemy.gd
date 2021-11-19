extends "res://fighter/Fighter.gd"

onready var sensor = $Sensor

const seperation_range = 25.0

var player = null

var movement_manager = MovementManager.new()

func _ready():
	movement_manager.init(self)

func _process(delta:float) -> void:
	var bodies = sensor.get_overlapping_bodies()
	bodies.erase(self)

	var global_player = get_tree().get_nodes_in_group("player")[0]
	for item in bodies:
		if item.is_in_group("player"):
			player = item
			bodies.erase(player)
	
	var nearest = null
	if(bodies.size() > 0):
		nearest = bodies[0]
		for body in bodies:
			if(position.distance_to(body.position) < position.distance_to(nearest.position)):
				nearest = body
	
	movement_manager.reset()
	
	if(global_player != null):
#		movement_manager.seek(global_player.position, 100.0, 1.0)
		movement_manager.pursuit(global_player, 1.0)
	
	for body in bodies:
		if body.position.distance_to(position) < seperation_range:
			movement_manager.flee(body.position, seperation_range * 15.0, 1.0)
	
	facing = movement_manager.calculate(100.0, 1.0)
	
	accelerating = true
	facing = facing.normalized()
	.steer(position + facing, max_velocity)
	
	turn_to(velocity.normalized())

##	acceleration = speed * facing
#	if player != null:
#		
#

#func steer(target:Vector2, velocity:Vector2) -> Vector2:
#	var steer = target - velocity
#	steer = steer.normalized() * steer_weight
#	return steer
#
#func seperate(bodies:Array) -> Vector2:
#	var vector = Vector2()
#	var close_bodies = []
#	for body in bodies:
#		if body.position.distance_to(position) < sensor.get_child(0).shape.radius / 2.0:
#			close_bodies.append(body)
#	if(close_bodies.size() == 0):
#		return vector
#	for body in close_bodies:
#		var difference = position - body.position
#		vector += difference.normalized()
#	vector /= close_bodies.size()
#	return steer(vector.normalized(), facing)
#
#func align(bodies:Array) -> Vector2:
#	var vector = Vector2()
#	if bodies.empty():
#		return vector
#	for body in bodies:
#		if(body != null):
#			vector += body.facing
#	vector /= bodies.size()
#	return steer(vector.normalized(), facing)
#
#func cohere(bodies:Array) -> Vector2:
#	var vector = Vector2()
#	if bodies.empty():
#		return vector
#	for body in bodies:
#		vector += body.position - position
#	vector /= bodies.size()
#	return steer((vector).normalized(), facing)
#
#func avoid(bodies:Array) -> Vector2:
#	return Vector2()
#
#func attract(bodies:Array) -> Vector2:
#	var vector = Vector2()
#	for body in bodies:
#		vector += (body.position - position)
#	vector /= bodies.size()
#	return steer(vector.normalized(), facing)
#
#func attract_to_point(points:Array) -> Vector2:
#	var vector = Vector2()
#	for point in points:
#		vector += (point - position)
#	vector /= points.size()
#	return steer(vector.normalized(), facing)

