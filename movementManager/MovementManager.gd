extends Object
class_name MovementManager

var steering: Vector2
var host: Fighter

func init(host: Fighter):
	steering = Vector2.ZERO
	self.host = host

# Methods:

func seek(target: Vector2, slowing_radius: float, weight: float):
	var desired_velocity = (target - host.position).normalized() * host.max_velocity
	var distance = (target-host.position).length()
	if distance <= slowing_radius:
		desired_velocity *= distance / slowing_radius
	var force = desired_velocity - host.velocity
	steering += force * weight
	return force*weight

func flee(target: Vector2, acceleration_radius: float, weight: float):
	var desired_velocity = (host.position - target).normalized() * host.max_velocity
	var distance = (host.position-target).length()
#	if distance <= acceleration_radius:
	desired_velocity *= acceleration_radius / distance
	var force = desired_velocity - host.velocity
	steering += force * weight
	return force*weight

func evade(target: Fighter, weight: float):
	var change = Vector2.ZERO
#	...
	steering += change

func pursuit(target: Fighter, weight: float, slowing_radius: float, delta_t: float):
	var prediction: Vector2 = (target.position + target.velocity * delta_t)
	return seek(prediction, slowing_radius, weight)
# ...

func avoid(target: Vector2, weight: float):
#	Assumes the velocity of host does intersect the target
	var ahead = host.position + host.velocity.normalized()
	var desired_velocity = ((ahead - host.position).normalized() - (target - host.position).normalized()).normalized() * host.max_velocity
	var force = desired_velocity + host.velocity
	steering += force * weight
	return force * weight

func separation(targets: Array, weight: float, seperation_range: float, power: float):
	var desired_velocity = Vector2.ZERO
	for target in targets:
#		desired_velocity += (host.position - target.position).normalized() * host.max_velocity
		desired_velocity += (host.position - target.position).normalized() *( pow(seperation_range / (host.position - target.position).length(),power) - 1)* host.max_velocity
	if targets.size() != 0:
		desired_velocity /= targets.size()

	var force = desired_velocity 
	steering += force * weight
	return force * weight

func align(targets: Array, weight: float):
	var desired_velocity = Vector2.ZERO
	for target in targets:
		desired_velocity += target.velocity
	if targets.size() != 0:
		desired_velocity /= targets.size()
	
	var force = desired_velocity
	steering += force * weight
	return force * weight

# Controlls:

func reset():
	steering = Vector2.ZERO

func get_steering() -> Vector2:
	return steering

func calculate(max_force: float, mass: float) -> Vector2:
	steering = (steering - host.velocity).clamped(max_force) / mass
	return steering
