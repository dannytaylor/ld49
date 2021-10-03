extends Spatial

onready var board = get_node("../Board")

onready var box_mid = get_node("box_middle")
onready var box_inner = get_node("box_middle/box_inner")
onready var hand_l = get_node("hand_l")
onready var hand_r = get_node("hand_r")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	var rx = board.rotation_degrees.x
	var rz = board.rotation_degrees.z
	
	hand_l.rotation_degrees.z = rz*4
	hand_r.rotation_degrees.x = rx*4
	box_mid.rotation_degrees.x = rx
	box_inner.rotation_degrees.z = rz
