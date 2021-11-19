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

func flee(target: Vector2, acceleration_radius: float, weight: float):
	var desired_velocity = (host.position - target).normalized() * host.max_velocity
	var distance = (host.position-target).length()
#	if distance <= acceleration_radius:
	desired_velocity *= acceleration_radius / distance
	var force = desired_velocity - host.velocity
	steering += force * weight

func evade(target: Fighter, weight: float):
	var change = Vector2.ZERO
#	...
	steering += change

const T = 2.0
func pursuit(target: Fighter, weight: float):
	var prediction: Vector2 = target.position + target.velocity * T
	seek(prediction, 1.0, weight)
# ...

# Controlls:

func reset():
	steering = Vector2.ZERO

func calculate(max_force: float, mass: float) -> Vector2:
	steering = steering.clamped(max_force) / mass
	return steering
