extends Obstacle
class_name OrbitCenter

signal orbiter_captured(orbiter: Orbiter)
signal orbiter_released(orbiter: Orbiter)

## Any Orbiter inside this radius can orbit this center.
@export var capture_radius := 160.0
## Angular speed in radians/sec (direction is chosen per orbiter).
@export var orbit_speed := 2.0
## 0 = unlimited.
@export var max_orbiters := 0
## Destroying the center releases orbiters on a tangent.
@export var release_on_destroy := true

var orbiters: Array[Orbiter] = []
var _zone: Area2D
var _shape: CircleShape2D

func _ready():
	super._ready()
	_zone = Area2D.new()
	var col := CollisionShape2D.new()
	_shape = CircleShape2D.new()
	_shape.radius = capture_radius
	col.shape = _shape
	_zone.add_child(col)
	_zone.body_entered.connect(_on_body_entered)
	_zone.body_exited.connect(_on_body_exited)
	add_child(_zone)

func set_capture_radius(r: float):
	capture_radius = r
	if _shape:
		_shape.radius = r

func _on_body_entered(body: Node):
	if body is Orbiter:
		capture(body)

func _on_body_exited(body: Node):
	if body is Orbiter and body.center == self:
		release(body)

func capture(orbiter: Orbiter) -> bool:
	if orbiter.center != null or not orbiter.can_be_captured():
		return false
	if max_orbiters > 0 and orbiters.size() >= max_orbiters:
		return false
	orbiters.append(orbiter)
	orbiter.begin_orbit(self)
	orbiter_captured.emit(orbiter)
	return true

func release(orbiter: Orbiter):
	if orbiter in orbiters:
		orbiters.erase(orbiter)
		orbiter.end_orbit()
		orbiter_released.emit(orbiter)

func release_all():
	for o in orbiters.duplicate():
		release(o)

func _destroy(by: Node, impact_speed: float):
	if release_on_destroy:
		release_all()
	super._destroy(by, impact_speed)