extends StaticBody2D

@onready var projectile = load("res://Entities/asteroid.tscn")
@onready var spawn_shape: CollisionShape2D = $Area2D/CollisionShape2D

@export var turn_speed := 10.0


func _ready():
	pass

func _process(delta):
	var dir = get_global_mouse_position() - global_position
	var target_angle = dir.angle() + PI / 2
	global_rotation = lerp_angle(global_rotation, target_angle, 1.0 - exp(-turn_speed * delta))

func _physics_process(delta):
	if Input.is_action_just_pressed("shoot"): shoot()

func shoot():
	var instance = projectile.instantiate()
	instance.spawn_pos = spawn_shape.global_position
	instance.spawn_rotation = global_rotation
	get_tree().current_scene.add_child.call_deferred(instance)

func _on_cooldown_timeout():
	shoot()
