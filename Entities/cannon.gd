extends StaticBody2D

@onready var projectile = load("res://Entities/asteroid.tscn")
@onready var spawn_shape: CollisionShape2D = $Area2D/CollisionShape2D

@export var turn_speed := 10.0
@export var speedup := 5.0
@export var maxSpeedMult := 3.0

var timeHolding := false
var shootHolding := false
var speedMult := 0.0

func _ready():
	pass

func _process(delta):
	var dir = get_global_mouse_position() - global_position
	var target_angle = dir.angle() + PI / 2
	global_rotation = lerp_angle(global_rotation, target_angle, 1.0 - exp(-turn_speed * delta))
	if Input.is_action_pressed("game_shoot") and shootHolding == false:
		shootHolding = true
		print("Charging")
	if Input.is_action_pressed("game_shoot") and shootHolding == true: 
		if speedMult < maxSpeedMult:
			speedMult += delta * 1.1
	if Input.is_action_just_released("game_shoot") and shootHolding == true:
		shootHolding = false
		print(speedMult)
		shoot(speedMult)
		speedMult = 0
		
func _input(event: InputEvent):
	if Input.is_action_pressed("game_slow") and timeHolding == false:
		timeHolding = true	
		Engine.time_scale = speedup
		print("Speed up.")
	if Input.is_action_just_released("game_slow") and timeHolding == true:
		Engine.time_scale = 1.0
		print("Slow down.")
		timeHolding	 = false
	

func _unhandled_input(event):
	if event.is_action_pressed("game_ammo_next"):
		switch_ammo(1)
	elif event.is_action_pressed("game_ammo_prev"):
		switch_ammo(-1)

func _physics_process(delta):
	pass

func shoot(mult: float):
	if not StageManager.consume_ammo():
		print("No more ammo")
		return
	var instance = projectile.instantiate()
	instance.spawn_pos = spawn_shape.global_position
	instance.spawn_rotation = global_rotation
	instance.speed *= 1 + mult
	instance.type = StageManager.selected_ammo_type  # assumes asteroid has a `type` property
	get_tree().current_scene.add_child.call_deferred(instance)

func switch_ammo(direction := 1) -> void:
	StageManager.cycle_ammo_type(direction)

func switch_ammo_to(type: GlobalEnums.AsteroidType) -> bool:
	if not StageManager.select_ammo_type(type):
		print("Ammo type %s not allowed on this stage" % type)
		return false
	return true