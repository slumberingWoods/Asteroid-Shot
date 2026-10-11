extends CharacterBody2D
class_name Asteroid

@export var type: GlobalEnums.AsteroidType:
	set(value):
		type = value
		if is_node_ready():
			apply_type()

@export_group("Per-type visuals")
@export var type_textures: Array[Texture2D] = [null, null, null]
@export var type_scales: Array[float] = [0.6, 1.0, 1.6]
@export var image_scales: Array[float] = [0.3, 0.3, 0.4]
@export var image_size: Array[float] = [60, 100, 160]

@export_group("Physics")
@export var size_impact_mult: Array[float] = [1.0, 1.5, 2.5]
@export var speed := 200.0
@export var accel := 0.3
@export var stop_speed := 5.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var spawn_pos : Vector2
var spawn_rotation : float
var is_shot := false
var _resolved := false
var _base_sprite_scale := Vector2.ONE
var _base_collision_scale := Vector2.ONE


func _ready():
	_base_sprite_scale = sprite.scale
	_base_collision_scale = collision_shape.scale
	apply_type()
	add_to_group("asteroids")
	if is_shot:
		add_to_group("shots")
	global_position = spawn_pos
	global_rotation = spawn_rotation
	velocity = Vector2.UP.rotated(spawn_rotation) * speed

func apply_type():
	var i := clampi(int(type), 0, type_scales.size() - 1)
	var tex_i := clampi(int(type), 0, type_textures.size() - 1)
	if not type_textures.is_empty() and type_textures[tex_i] != null:
		sprite.texture = type_textures[tex_i]
	var s := type_scales[i]
	var b := image_scales[i]
	sprite.scale = _base_sprite_scale * b
	collision_shape.scale = _base_collision_scale * s

func _physics_process(delta: float):
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