extends Spatial

export(float) var lifetime = 0.20
export(float) var max_size = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	$Lifetime.wait_time = lifetime
	$Lifetime.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var pct_done = 1.0 - ($Lifetime.time_left / lifetime)
	$MeshInstance.scale.x = max_size * pct_done
	$MeshInstance.scale.z = max_size * pct_done


func _on_Lifetime_timeout():
	for child in self.get_children():
		child.queue_free()
	self.queue_free()
