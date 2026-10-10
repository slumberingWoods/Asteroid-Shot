extends Node2D

@export var max_health := 10
var health : float

func _ready() -> void:
	health = max_health

func modHealth(damage: int):
	health -= damage
	
	if health <= 0:
		get_parent().queue_free()

func _process(delta: float) -> void:
	pass
