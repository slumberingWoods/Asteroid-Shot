extends Node2D

@onready var main = get_tree().get_root().get_node("main")
@onready var projectile = load("res://asteroid.tscn")

func _ready():
    pass

func shoot():
    var instance = projectile.instantiate()
    instance.direction = rotation
    instance.spawnPos = global_position
    instance.spawnRotation = rotation
    main.add_child.call_deferred(instance)
    
func _on_cooldown_timeout():
    shoot()