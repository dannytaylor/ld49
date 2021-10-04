extends RigidBody

export(String, "melee", "ranged") var attack_type = "melee"
export(float) var attack_range = 0.25
export(float) var attack_time = 1.5
export(float) var attack_backswing = 3.0

var is_attacking = false
var is_backswing = false

var hero_obj = null

# Called when the node enters the scene tree for the first time.
func _ready():
	hero_obj = get_node("../Hero")
	$AttackTimer.wait_time = attack_time
	$BackswingTimer.wait_time = attack_backswing

func _hero_in_range():
	var distance = self.global_transform.origin.distance_squared_to(hero_obj.global_transform.origin)
	if distance <= attack_range:
		return true
	return false

func _attempt_attack():
	# Doublecheck if close enough
	if _hero_in_range() == false:
		# Can't attack, we're done here
		return
	
	if attack_type == "melee":
		var slashscn = load("res://objects/attacks/slash.tscn")
		var slash = slashscn.instance()
		slash.global_transform.origin = self.global_transform.origin
		slash.look_at(hero_obj.global_transform.origin, Vector3(0, 1, 0))
		slash.rotate_object_local(Vector3(0,1,0), 3.14)
		self.get_parent().add_child(slash)
	if attack_type == "ranged":
		var arrowscn = load("res://objects/attacks/arrow.tscn")
		var arrow = arrowscn.instance()
		arrow.look_at(hero_obj.global_transform.origin, Vector3(0, 1, 0))
		arrow.rotate_object_local(Vector3(0,1,0), 3.14)
		self.get_parent().add_child(arrow)
		# Create a path for the arrow to follow
		var midpoint_x = (self.global_transform.origin.x + hero_obj.global_transform.origin.x) / 2
		var midpoint_z = (self.global_transform.origin.z + hero_obj.global_transform.origin.z) / 2
		var curve = Curve3D.new()
		curve.clear_points()
		
		curve.add_point(hero_obj.global_transform.origin)
		curve.add_point(Vector3(midpoint_x, hero_obj.global_transform.origin.y + 1, midpoint_z))
		curve.add_point(self.global_transform.origin)
		
		arrow.get_path().curve = curve
		arrow.global_transform.origin = self.global_transform.origin
		

func _check_attack():
	if is_attacking == false and is_backswing == false:
		# Check if close enough
		if _hero_in_range() == true:
			# We can start an attack
			is_attacking = true
			$AttackTimer.start()
	elif is_attacking == true:
		# How far along in the attack are we?/
		var anim_pct = 1 - ($AttackTimer.time_left / attack_time)
	elif is_backswing == true:
		var anim_pct = 1 - ($BackswingTimer.time_left / attack_time)
	
func _process(delta):
	pass

func _on_AttackTimer_timeout():
	is_attacking = false
	is_backswing = true
	_attempt_attack()
	$BackswingTimer.start()


func _on_BackswingTimer_timeout():
	is_attacking = false
	is_backswing = false
	

func _on_CheckTimer_timeout():
	_check_attack()
