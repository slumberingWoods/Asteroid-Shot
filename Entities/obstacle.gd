extends StaticBody2D
class_name Obstacle

signal damaged(amount: float, health_left: float)
signal destroyed(by: Node, impact_speed: float)

@export var min_impact_speed := 80.0
@export var max_health := 100.0
@export var damage_per_speed := 0.5
@export_range(0.0, 1.0) var momentum_retained := 0.6
@export var debris_scene: PackedScene

var health : float

func _ready() -> void:
	health = max_health

func take_impact(impact_speed: float, by: Node = null) -> bool:
	if impact_speed < min_impact_speed:
		return false

	var dmg := (impact_speed - min_impact_speed) * damage_per_speed + 1.0
	health -= dmg
	damaged.emit(dmg, health)

	if health <= 0.0:
		_destroy(by, impact_speed)
		return true
	return false

func _destroy(by: Node, impact_speed: float) -> void:
	destroyed.emit(by, impact_speed)
	if debris_scene:
		var d := debris_scene.instantiate()
		d.global_position = global_position
		get_parent().add_child.call_deferred(d)
	queue_free()
