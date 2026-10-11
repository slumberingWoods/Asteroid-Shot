extends CharacterBody2D
class_name Orbiter

signal orbit_started(center: OrbitCenter)
signal orbit_ended(center: OrbitCenter)

@export var recapture_cooldown := 1.0
@export var min_orbit_radius := 8.0

var center: OrbitCenter = null

var _angle := 0.0
var _radius := 0.0
var _angular_speed := 0.0 
var _cooldown := 0.0

func can_be_captured() -> bool:
	return center == null and _cooldown <= 0.0

## Move closer to / farther from the center while orbiting.
## Clamped to the center's capture radius.
func set_orbit_radius(r: float) -> void:
	_radius = clampf(r, min_orbit_radius, center.capture_radius if center else r)

func begin_orbit(c: OrbitCenter) -> void:
	center = c
	var offset := global_position - c.global_position
	_angle = offset.angle()
	_radius = maxf(offset.length(), min_orbit_radius)

	# Keep the direction the body was already travelling around the center.
	var dir := signf(offset.cross(velocity))
	if dir == 0.0:
		dir = 1.0
	_angular_speed = c.orbit_speed * dir

	c.tree_exiting.connect(_on_center_gone, CONNECT_ONE_SHOT)
	orbit_started.emit(c)

func end_orbit() -> void:
	if center == null:
		return
	var old := center
	if old.tree_exiting.is_connected(_on_center_gone):
		old.tree_exiting.disconnect(_on_center_gone)

	# Leave along the tangent at the current orbital speed.
	var dir := signf(_angular_speed)
	velocity = Vector2.from_angle(_angle + dir * PI / 2.0) * absf(_angular_speed) * _radius
	center = null
	_cooldown = recapture_cooldown
	orbit_ended.emit(old)

func _on_center_gone() -> void:
	if center:
		center.orbiters.erase(self)
		end_orbit()

func _physics_process(delta: float) -> void:
	_cooldown = maxf(_cooldown - delta, 0.0)

	if center == null:
		move_and_slide()
		return

	# If the capture zone shrank past us, we're out of range.
	if _radius > center.capture_radius:
		center.release(self)
		return

	_angle += _angular_speed * delta
	global_position = center.global_position + Vector2.from_angle(_angle) * _radius