extends "res://fighter/Fighter.gd"

onready var sensor = $Sensor

const seperation_range = 15.0

var player = null

var movement_manager = MovementManager.new()

var state = 0

func _ready():
	movement_manager.init(self)

var seperation = Vector2.ZERO
var steering = Vector2.ZERO
var pursuit = Vector2.ZERO

func _process(delta:float) -> void:
	var bodies = sensor.get_overlapping_bodies()
	bodies.erase(self)
	
	max_velocity = 500

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
		movement_manager.seek(global_player.position, 10.0, 1.0)
	pursuit = pursuit.linear_interpolate(movement_manager.get_steering(), 0.03)
	
	var too_close = []
	var to_align = []
	if player != null && player.position.distance_to(position) < seperation_range * 3:
#		movement_manager.flee(player.position, 10.0, 2.0)
#		too_close.append(player)
		movement_manager.avoid(player.position, 1.5)
	for body in bodies:
		if body.position.distance_to(position) < seperation_range:
			if (body.position - position).normalized().dot(velocity.normalized()) > 0.8:
				movement_manager.avoid(body.position, 1.0)
			else:
				too_close.append(body)
		if body.position.distance_to(position) < seperation_range * 3:
			to_align.append(body)
#			movement_manager.flee(body.position, 10.0,  1.0)
	seperation = seperation.linear_interpolate(movement_manager.separation(too_close, 1.0, seperation_range, 2), 0.03)
#	movement_manager.align(to_align, 1.0)
	steering = steering.linear_interpolate(movement_manager.get_steering(), 0.03)
	
	facing = movement_manager.calculate(100.0, 1.0)
	update()
	turn_to((velocity) / 3)
	if facing.normalized().dot(velocity.normalized()) > 0.3 && facing.length() > 25:
		accelerating = true
	else:
		accelerating = false
	facing = facing.normalized()
	
	.steer(position + facing, max_velocity)

	$RayCast2D.cast_to = (velocity.normalized() * 500)
	if player != null:
		if $RayCast2D.get_collider() == player && facing.normalized().dot((player.position - position).normalized()) > 0.99:
			fire_laser(facing.normalized(), Color(4,1,1))

func _draw():
#	draw_line(Vector2.ZERO, seperation / 150 * seperation_range, Color.red)
#	draw_line(Vector2.ZERO, pursuit / 150  * seperation_range, Color.blue)
#	draw_line(Vector2.ZERO, steering / 150  * seperation_range, Color.purple)
#	draw_line(Vector2.ZERO, facing.normalized() * 10, Color.magenta)
#	draw_empty_circle(Vector2.ZERO, seperation_range, Color.red, 1)
	pass

func draw_empty_circle(center: Vector2, radius: float, color: Color, resolution: int):
	var draw_counter = 1
	var line_origin = Vector2()
	var line_end = Vector2()
	line_origin = center + Vector2.RIGHT * radius
	
	while draw_counter <= 360:
		line_end = Vector2.RIGHT.rotated(deg2rad(draw_counter)) * radius + center
		draw_line(line_origin, line_end, color)
		draw_counter += 1 / resolution
		line_origin = line_end
	
	line_end = Vector2.RIGHT.rotated(deg2rad(360)) * radius + center
	draw_line(line_origin, line_end, color)

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

