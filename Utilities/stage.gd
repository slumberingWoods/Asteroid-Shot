extends Node

class_name Stage

@export var ammo := 1
@export var allowed_sizes : Array[GlobalEnums.AsteroidType] = []
@export var length := 1000
@export var width := 500

func _enter_tree():
	StageManager.adopt_stage(self)
