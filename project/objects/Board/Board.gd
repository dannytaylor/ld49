extends RigidBody

const max_tilt = 8
const mouse_adjust = 0.05
var mouse_delta = Vector2.ZERO

onready var box_mid = get_node("../box_outer/box_middle")
onready var box_inner = get_node("../box_outer/box_middle/box_inner")

onready var hand_l = get_node("../hand_l")
onready var hand_r = get_node("../hand_r")

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass # Replace with function body.

func _physics_process(delta):
	
	rotation_degrees.x += mouse_delta.x
	rotation_degrees.x = clamp(rotation_degrees.x, -max_tilt, max_tilt)
	box_mid.rotation_degrees.x = rotation_degrees.x
	hand_r.rotation_degrees.z = 180-rotation_degrees.x*4
	
	rotation_degrees.z += mouse_delta.y
	rotation_degrees.z = clamp(rotation_degrees.z, -max_tilt, max_tilt)
	box_inner.rotation_degrees.z = rotation_degrees.z
	hand_l.rotation_degrees.z = rotation_degrees.z*4
	
	mouse_delta = Vector2.ZERO
	
	
func _input(event):
	if event is InputEventMouseMotion:
		mouse_delta = event.relative * mouse_adjust
