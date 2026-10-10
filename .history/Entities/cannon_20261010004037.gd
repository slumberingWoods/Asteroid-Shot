extends Node2D

@onready var projectile = load("res://Entities/asteroid.tscn")

func _ready():
    pass

func _physics_process(delta):
	## rotation_degrees += 50 * delta 
	if Input.is_action_just_pressed("shoot"): shoot()

func shoot():
	var instance = projectile.instantiate()
	instance.spawn_pos = global_position
	instance.spawn_rotation = global_rotation
	get_tree().current_scene.add_child.call_deferred(instance)

func _on_cooldown_timeout():
	shoot()
