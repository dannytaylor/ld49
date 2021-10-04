extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_hole_body_entered(body):
	
	if body.is_in_group("enemy"):
		body.collision_layer = 0
		body.collision_mask = 0
