extends Node2D

@onready var main = get_tree().get_root().get_node("main")
@onready var projectile = load("res://Entities/asteroid.tscn")

func _ready():
	shoot()

func _physics_process(delta):
	rotation_degrees += 50 * delta

func shoot():
	var instance = projectile.instantiate()
	instance.dir = rotation
	instance.spawnPos = global_position
	instance.spawnRotation = rotation
	main.add_child.call_deferred(instance)
	
func _on_cooldown_timeout():
	shoot()
