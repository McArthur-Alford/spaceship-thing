extends KinematicBody2D
class_name Fighter

var velocity:Vector2 = Vector2.ZERO
var acceleration:Vector2 = Vector2.ZERO
export var max_velocity:float = 200.0
export var speed:float = 10.0

onready var sprite:Sprite = $Sprite
onready var plume:Particles2D = $Sprite/Plume
export var plume_count:float = 0.2
export var plume_count_min:float = 0.1
export var sprite_squish_threshold:float = 0.9 # 0.9 recommended
export var turn_range:float = 0.6
export var sprite_turn_min:float = 0.5

var mouse_pos:Vector2 = Vector2()
var mouse_dir:Vector2 = Vector2()

var facing:Vector2 = Vector2.UP

var accelerating:bool = true

onready var projectile:Object = load("res://laser/projectile.tscn")
onready var firepoints:Array = [$Sprite/FP1, $Sprite/FP2]
var firepoint = 0
var reloaded = true
onready var reload_timer:Timer = $Reload

var health:int = 100
onready var explosion = load("res://explosion/explosion.tscn")

const max_steering_accel = 5.0

func turn_to(desired_facing:Vector2) -> void:
#	var facing = Vector2(cos(deg2rad(sprite.rotation_degrees)), sin(deg2rad(sprite.rotation_degrees)))
#	sprite.rotation_degrees = rad2deg(facing.slerp(desired_facing, 0.8).angle() + PI / 4)
	sprite.rotation_degrees = rad2deg((desired_facing).angle() + PI / 2)

func _process(delta:float):
	mouse_pos = get_global_mouse_position()
	mouse_dir = (mouse_pos - position).normalized()
	
	# Plume Calculation:
	var desired_plume = max(max(velocity.normalized().dot(mouse_dir),0.5)*plume_count,plume_count_min)
	plume.lifetime = desired_plume
	if(not accelerating):
		plume.emitting = false
	else:
		plume.emitting = true
	
	# Sprite Manipulation:
#	if(abs(facing.dot(velocity.normalized())) < turn_range and accelerating):
#		sprite.scale.x = pow(max(abs(facing.dot(velocity.normalized())), sprite_turn_min)/turn_range,2)
#	else:
#		sprite.scale.x = 1.0
#	if(velocity.normalized().dot(facing) < -sprite_squish_threshold  and accelerating):
#		sprite.scale.y = (abs(velocity.normalized().dot(facing))-(sprite_squish_threshold - 0.1))/(1 - sprite_squish_threshold + 0.2)
#	else:
#		sprite.scale.y = 1.0

func _physics_process(delta:float) -> void:
	velocity += acceleration
	velocity = move_and_slide(velocity)
	
	if velocity.length() > max_velocity:
#		velocity = velocity.linear_interpolate(max_velocity * velocity.normalized(), 0.1)
		velocity = velocity.clamped(max_velocity)


func _on_Reload_timeout() -> void:
	reloaded = true

func deload() -> void:
	reloaded = false
	reload_timer.start()

func fire_laser():
	if reloaded:
		deload()
		var instance = projectile.instance()
		instance.position = firepoints[firepoint].global_position
		firepoint = (firepoint + 1) % firepoints.size()
		instance.direction = mouse_dir
		instance.friend = self
		instance.calculate_rotation()
		get_tree().current_scene.add_child(instance)

func damage(damage:int) -> void:
	health -= damage
	if(health < 0):
		kill()

func kill() -> void:
	explode()
	queue_free()

func explode() -> void:
	var instance = explosion.instance()
	randomize()
	instance.initialize(position,velocity,1)
	get_tree().current_scene.add_child(instance)

func steer(target, desired_speed):
	var desired_velocity = (target - position).normalized() * desired_speed
	var steer = (desired_velocity - velocity).clamped(max_steering_accel)
	acceleration = steer

func thrust(target, force):
	target = target.normalized()
	acceleration = target * force
