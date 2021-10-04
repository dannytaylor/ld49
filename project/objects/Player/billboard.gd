extends Spatial

onready var sprite = $Sprite3D
onready var label = $Sprite3D/Label

func get_camera():
	var r = get_node('/root')
	return r.get_viewport().get_camera()

func position_label(label:Label, point3D:Vector3):
	var camera = get_camera()
	var cam_pos = camera.translation
	var offset = Vector2(label.get_size().x/2, 0)
	label.rect_position = camera.unproject_position(point3D) - offset

func set_label(text):
	$Sprite3D/Label.text = text

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	var cam = get_camera()
	var test_point:Vector3 = sprite.global_transform.origin
	position_label(label, test_point)
