extends CharacterBody2D

class_name Asteroid

@export var SPEED = 100
@export var ACCEL = -5

var direction : float
var spawnPos : Vector2
var spawnRotation : float

func _ready():
    global_position = spawnPos
    global_rotation = spawnRotation

func _physics_process(_delta):
    velocity = Vector2(0, -SPEED).rotated(direction)
    move_and_slide()