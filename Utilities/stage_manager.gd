extends Node

signal stage_changed(stage: Node)
signal ammo_changed(amount: int)
signal ammo_type_selected(type: GlobalEnums.AsteroidType)
signal enemies_changed(remaining: int)
signal stage_cleared
signal stage_failed

var stages: Array[PackedScene] = [
	preload("res://Stages/1_st_stage.tscn"),
	preload("res://Stages/2_nd_stage.tscn"),
]
 
var current_stage: Stage = null
var stage_size := Vector2.ZERO
var current_stage_index := -1

var ammo := 0
var shots_in_flight := 0
var allowed_ammo_types: Array[GlobalEnums.AsteroidType] = []
var selected_ammo_type: GlobalEnums.AsteroidType
var enemies_remaining := 0
 
var _container: Node = null
var _finished := false  

func set_stage_container(container: Node):
	_container = container

# ---------- Stage lifecycle ----------
func load_stage(index: int):
	if index < 0 or index >= stages.size():
		push_error("StageManager: invalid stage index %d" % index)
		return
	_unload_current()
	current_stage_index = index
	current_stage = stages[index].instantiate() as Stage
	_init_from_stage(current_stage)
	(_container if _container else get_tree().current_scene).add_child(current_stage)
	stage_changed.emit(current_stage)

func next_stage():
	load_stage(current_stage_index + 1)

func restart_stage():

	load_stage(current_stage_index)
func _unload_current():
	_finished = true
	get_tree().call_group("shots", "queue_free")
	get_tree().call_group("asteroids", "queue_free")
	if is_instance_valid(current_stage):
		current_stage.queue_free()
	current_stage = null

func unload_stage():
	_unload_current()
	current_stage_index = -1

func _init_from_stage(stage: Node): 
	_finished = false
	shots_in_flight = 0
	ammo = stage.ammo
	stage_size = Vector2(stage.width, stage.length)
	allowed_ammo_types = stage.allowed_sizes.duplicate()
	enemies_remaining = 0  # enemies register themselves as they spawn
	if not allowed_ammo_types.is_empty():
		selected_ammo_type = allowed_ammo_types[0]
 
	ammo_changed.emit(ammo)
	ammo_type_selected.emit(selected_ammo_type)
	enemies_changed.emit(enemies_remaining)

func adopt_stage(stage: Stage):
	if stage == current_stage:
		return
	current_stage = stage
	current_stage_index = stages.find_custom(
		func(s: PackedScene): return s.resource_path == stage.scene_file_path)
	_init_from_stage(stage)
	stage_changed.emit(stage)

# ---------- Ammo ----------
func is_ammo_type_allowed(type: GlobalEnums.AsteroidType) -> bool:
	return type in allowed_ammo_types
func select_ammo_type(type: GlobalEnums.AsteroidType) -> bool:
	if not is_ammo_type_allowed(type):
		return false
	selected_ammo_type = type
	ammo_type_selected.emit(type)
	return true
func cycle_ammo_type(direction := 1):
	if allowed_ammo_types.is_empty():
		return
	var i := allowed_ammo_types.find(selected_ammo_type)
	select_ammo_type(allowed_ammo_types[wrapi(i + direction, 0, allowed_ammo_types.size())])
## Returns true if a shot was available and consumed.
func consume_ammo(amount := 1) -> bool:
	if _finished or ammo < amount:
		return false
	ammo -= amount
	shots_in_flight += amount
	ammo_changed.emit(ammo)
	return true
func add_ammo(amount: int):
	ammo += amount
	ammo_changed.emit(ammo)

# ---------- Enemies ----------
func register_enemy(count := 1):
	enemies_remaining += count
	enemies_changed.emit(enemies_remaining)
func unregister_enemy():
	enemies_remaining = maxi(enemies_remaining - 1, 0)
	enemies_changed.emit(enemies_remaining)
	_check_end_conditions()

## Call when a shot is spent (e.g. projectile hit or left the stage),
## so "out of ammo" is only judged once nothing is still in flight.
func notify_shot_resolved():
	shots_in_flight = maxi(shots_in_flight - 1, 0)
	_check_end_conditions()

# ---------- Win / lose ----------
func _check_end_conditions():
	if _finished:
		return
	if enemies_remaining == 0:
		_finished = true
		stage_cleared.emit()
	elif ammo <= 0 and shots_in_flight == 0:
		_finished = true
		stage_failed.emit()
