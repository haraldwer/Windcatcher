class_name Movement
extends CharacterBody3D

var input_vector = Vector2.ZERO
var input_look = Vector2.ZERO

const GRAVITY = -30.0
const BOYANCY = 50.0
const BOYANCY_OFFSET = 0.5
const BOYANCY_ALIGNMENT = 2.0
const FRICTION = 2.0
const MAX_SPEED = 50.0
const SPEED_CHANGE = 15.0
const ACCELERATION = 20.0
const RETARDATION = 1.0
var speed = 0.0 # Current speed
var target_speed = 0.0 # Target speed

const UP_THRESHOLD = 0.2
const UP_MULTIPLIER = 1.2
const UP_FRICTION = 5.0
var up_total = 0.0 # Upwards foce thing
var up_target = 0.0 # Target value

const SENSITIVITY = 0.001
const ROTATION_SPEED = 10.0
const TILT = 2.0
var aim_rotation = Vector3.ZERO

const WIND_ACC = 80.0
const WIND_ROT = 10.0
const MIN_WIND = 0.3
var wind

func _ready():
	wind = get_parent().get_node("Wind")
	pass

func _set_input(vector, look):
	input_vector = vector
	input_look = look
	pass

func _process(delta):
	target_speed += SPEED_CHANGE * input_vector.y; 
	target_speed = clamp(target_speed, 0.0, MAX_SPEED)
	
	if speed < target_speed: 
		speed += ACCELERATION * delta
	else: 
		speed = lerp(speed, 0.0, RETARDATION * delta)
	speed = clamp(speed, 0.0, MAX_SPEED)
	
	aim_rotation.x += SENSITIVITY * input_look.y
	aim_rotation.y += SENSITIVITY * input_look.x
	pass

func _physics_process(delta):
	
	# Friction
	velocity = lerp(velocity, Vector3.ZERO, FRICTION * delta)
	
	# Thrust
	var direction = -global_transform.basis.z
	var thrust = direction * speed
	if direction.y > 0:
		thrust.y *= 1 - direction.y * 0.5
	velocity += thrust * delta
	
	# Updwards speed
	up_total += (speed / MAX_SPEED) * delta
	if up_total > up_target:
		velocity.y -= up_total * GRAVITY * UP_MULTIPLIER
		up_total = 0
		up_target = UP_THRESHOLD # + random()
	
	# Wind
	var wind_dir = wind.get_wind();
	if wind_dir != Vector3.ZERO:
		var wind_dot = wind_dir.dot(-global_transform.basis.z)
		var wind_mul = clamp(max(wind_dot, 0.0) + MIN_WIND, 0.0, 1.0)
		velocity += wind_dir * WIND_ACC * delta * wind_mul;
	
	# Gravity
	velocity.y += GRAVITY * delta
	
	# Boyancy
	var depth = min(global_position.y - BOYANCY_OFFSET, 0.0);
	velocity.y -= depth * BOYANCY * delta
	global_rotation.x = lerp(global_rotation.x, 0.0, -depth * BOYANCY_ALIGNMENT * delta)
	rotation.z = lerp(rotation.z, 0.0, -depth * BOYANCY_ALIGNMENT * delta)
	
	# Rotation
	var rot_quat = Quaternion.from_euler(global_rotation)
	var aim_quat = Quaternion.from_euler(aim_rotation)
	var rot_speed = ROTATION_SPEED * (speed / MAX_SPEED)
	global_rotation = rot_quat.slerp(aim_quat, rot_speed * delta).get_euler()
	
	# Tilt
	var flat_vel = (velocity * Vector3(1.0, 0.0, 1.0)).normalized()
	var flat_dir = (direction * Vector3(1.0, 0.0, 1.0)).normalized()
	var dot = flat_vel.dot(flat_dir.cross(Vector3.UP))
	rotation.z = min(abs(dot * TILT), PI * 0.5) * sign(dot)
	
	move_and_slide()
	pass
