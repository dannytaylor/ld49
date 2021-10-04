extends Spatial

export(float) var lifetime = 0.66
export(float) var radius  = 0.1

var target = null

# Called when the node enters the scene tree for the first time.
func _ready():
	$Lifetime.wait_time = lifetime
	$Lifetime.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var pct_done = 1.0 - ($Lifetime.time_left / lifetime)
	
	# Travel along the path
	$ArrowPath/PathFollow.unit_offset = pct_done
	
func _try_hit_target():
	if target == null:
		return
	
	if is_instance_valid(target) == false:
		return
	
	var otherpos = target.global_transform.origin
	var mypos = $ArrowPath/PathFollow/shaft.global_transform.origin
	var distance = mypos.distance_squared_to(otherpos)
	if distance <= radius:
		target.get_hit(1)

func _on_Lifetime_timeout():
	_try_hit_target()
	for child in self.get_children():
		child.queue_free()
	self.queue_free()

func get_path():
	return $ArrowPath
