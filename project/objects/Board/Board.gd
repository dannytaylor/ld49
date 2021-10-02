extends RigidBody

const max_tilt = 15
const mouse_adjust = 0.05
var mouse_delta = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass # Replace with function body.

func _physics_process(delta):
	
	rotation_degrees.x += mouse_delta.x
	rotation_degrees.x = clamp(rotation_degrees.x, -max_tilt, max_tilt)
	
	rotation_degrees.z += mouse_delta.y
	rotation_degrees.z = clamp(rotation_degrees.z, -max_tilt, max_tilt)
	
	mouse_delta = Vector2.ZERO
	
	
func _input(event):
	if event is InputEventMouseMotion:
		mouse_delta = event.relative * mouse_adjust
