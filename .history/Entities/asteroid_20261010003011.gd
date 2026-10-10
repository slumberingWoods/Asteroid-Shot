extends CharacterBody2D
class_name Asteroid

@export var speed := 100.0
@export var accel := -5.0

var spawn_pos : Vector2
var spawn_rotation : float

func _ready():
    global_position = spawn_pos
    global_rotation = spawn_rotation

func _physics_process(delta):
    speed = max(speed + accel * delta, 0.0)
    velocity = Vector2(0, -speed).rotated(rotation)
    move_and_slide()