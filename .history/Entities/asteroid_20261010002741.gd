extends CharacterBody2D

class_name Asteroid

@export var SPEED = 100
@export var ACCEL = -5

var dir : float
var spawnPos : Vector2
var spawnRotation : float

func _ready():
    global_position = spawnPos
    global_rotation = spawnRotation

func _physics_process(delta):
    velocity = Vector2(0, -SPEED).rotated(dir)
    move_and_slide()