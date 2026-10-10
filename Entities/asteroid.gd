extends CharacterBody2D
class_name Asteroid

@export var type: GlobalEnums.AsteroidType
@export var size_impact_mult: Array[float] = [1.0, 1.5, 2.5]
@export var speed := 200.0
@export var accel := 0.3
@export var stop_speed := 5.0

var spawn_pos : Vector2
var spawn_rotation : float
var is_shot := false
var _resolved := false

func _ready():
	if is_shot:
		add_to_group("shots")
	global_position = spawn_pos
	global_rotation = spawn_rotation
	velocity = Vector2.UP.rotated(spawn_rotation) * speed

func _physics_process(delta: float) -> void:
	velocity *= exp(-accel * delta)
	if velocity.length() < stop_speed:
		velocity = Vector2.ZERO
		if is_shot and not _resolved:
			_resolved = true
			StageManager.notify_shot_resolved()

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
	elif other is Obstacle:
		var impact_speed = maxf(-velocity.dot(n), 0.0) * get_impact_mult()
		if other.take_impact(impact_speed, self):
			velocity *= other.momentum_retained
		else:
			velocity = velocity.bounce(n)
	else:
		velocity = velocity.bounce(n)


func get_impact_mult() -> float:
	return size_impact_mult[clampi(int(type), 0, size_impact_mult.size() - 1)]
