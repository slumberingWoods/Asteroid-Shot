extends CharacterBody2D
class_name Asteroid

@export var speed := 200.0
@export var accel := 0.3
@export var stop_speed := 5.0

var spawn_pos : Vector2
var spawn_rotation : float

func _ready():
	global_position = spawn_pos
	global_rotation = spawn_rotation
	velocity = Vector2.UP.rotated(spawn_rotation) * speed
	print("launch speed: ", speed, " velocity: ", velocity.length())

func _physics_process(delta: float) -> void:
	velocity *= exp(-accel * delta)
	if velocity.length() < stop_speed:
		velocity = Vector2.ZERO

	var collision = move_and_collide(velocity * delta)
	if not collision:
		return

	var n = collision.get_normal()
	var other = collision.get_collider()

	if other is Asteroid:
		var along = (velocity - other.velocity).dot(n)
		if along < 0.0:
			velocity -= along * n
			other.velocity += along * n
	else:
		velocity = velocity.bounce(n)
