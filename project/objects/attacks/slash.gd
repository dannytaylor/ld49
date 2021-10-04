extends Spatial

export(float) var lifetime = 0.15
export(float) var speed = 5.0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Lifetime.wait_time = lifetime
	$Lifetime.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	translate(Vector3(0, 0, delta * speed))
	pass


func _on_Lifetime_timeout():
	for child in self.get_children():
		child.queue_free()
	self.queue_free()
