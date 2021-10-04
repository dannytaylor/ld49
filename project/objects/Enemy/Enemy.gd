extends RigidBody

export(String, "melee", "ranged") var attack_type = "melee"
export(float) var attack_range = 4.5
export(float) var attack_time = 0.75
export(float) var attack_backswing = 3.0
export(int) var health = 1
export(int) var armor = 1
export(int) var damage = 2

var current_health = 0
var current_armor = 0

var is_attacking = false
var is_backswing = false

var hero_obj = null
var spawner = null

# Called when the node enters the scene tree for the first time.
func _ready():
	hero_obj = get_node("../Board/Hero")
	$AttackTimer.wait_time = attack_time
	$BackswingTimer.wait_time = attack_backswing
	current_health = health
	current_armor = armor

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
	
	$baddie01_mesh/AnimationPlayer.play("Attack|mixamocom|Layer0")
	$baddie02_mesh/AnimationPlayer.play("Armature|CINEMA_4D_Main|Layer0")
	if attack_type == "melee":
		var slashscn = load("res://objects/attacks/slash-enemy.tscn")
		var slash = slashscn.instance()
		$EnemyHit.play()
		slash.global_transform.origin = self.global_transform.origin
		slash.look_at(hero_obj.global_transform.origin, Vector3(0, 1, 0))
		slash.rotate_object_local(Vector3(0,1,0), 3.14)
		self.get_parent().add_child(slash)
		hero_obj.get_hit(damage)
	if attack_type == "ranged":
		var arrowscn = load("res://objects/attacks/arrow.tscn")
		var arrow = arrowscn.instance()
		arrow.look_at(hero_obj.global_transform.origin, Vector3(0, 1, 0))
		#arrow.rotate_object_local(Vector3(0,1,0), 3.14)
		arrow.target = hero_obj
		# Create a path for the arrow to follow
		var midpoint_x = (self.global_transform.origin.x + hero_obj.global_transform.origin.x) / 2
		var midpoint_z = (self.global_transform.origin.z + hero_obj.global_transform.origin.z) / 2
		var curve = Curve3D.new()
		curve.clear_points()
		
		curve.add_point(hero_obj.global_transform.origin)
		curve.add_point(Vector3(midpoint_x, hero_obj.global_transform.origin.y + 1, midpoint_z))
		curve.add_point(self.global_transform.origin)
		arrow.get_path().curve = curve
		
		self.get_parent().add_child(arrow)
		arrow.global_transform.origin = self.global_transform.origin
		

func kill_enemy(award_xp):
	for child in self.get_children():
		child.queue_free()
	self.queue_free()
	if spawner != null:
		spawner.notify_spawn_death(self, award_xp)
	if hero_obj != null:
		if award_xp:
			hero_obj.level += 1

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

func _check_fall_through_floor():
	if global_transform.origin.y <= -10:
		# Fell...
		self.kill_enemy(false)

func _check_health_removed():
	if current_health <= 0:
		self.kill_enemy(true)
		hero_obj.get_node('KillSound').play()

func register_spawn():
	spawner.register_spawn_active(self)

func get_hit(dmg):
	if current_armor > 0:
		armor -= dmg
		if armor < 0:
			armor = 0
		return
	current_health -= dmg
	return

func _process(delta):
	_check_fall_through_floor()
	_check_health_removed()

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

func _on_ArmorUp_timeout():
	current_armor += 1
	if current_armor > armor:
		current_armor = armor
