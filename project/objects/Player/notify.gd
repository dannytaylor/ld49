extends Spatial

var lifetime = 1.66
var fadetime = 0.5
var speed = 7

var alive = true


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
	$Timer.wait_time = lifetime
	$Timer.start()

func _process(delta):
	self.translate(Vector3(0, 0, speed * delta * -1))
	if alive == false:
		var pct = 1 - ($Timer.time_left / fadetime)
		$Sprite3D.opacity = 1 - pct
	
	var cam = get_camera()
	var test_point:Vector3 = sprite.global_transform.origin
	position_label(label, test_point)


func _on_Timer_timeout():
	if alive:
		alive = false
		$Timer.wait_time = fadetime
		$Timer.start()
	else:
		self.get_parent().remove_child(self)

func set_modulate(color):
	$Sprite3D.modulate = color
	$Sprite3D/Label.set("custom_colors/font_color",color)
