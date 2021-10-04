extends MeshInstance

var attack_charged = false
var bow_charged = false

export(float) var health = 100.0 setget _set_health
export(float) var level = 1 setget _set_level

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	_colorize_gui()

func _colorize_gui():
	var atkpct = $AttackChargeTimer.time_left / $AttackChargeTimer.wait_time
	if $AttackChargeTimer.is_stopped():
		atkpct = 1.0
	var bowpct = $BowChargeTimer.time_left / $BowChargeTimer.wait_time
	if $BowChargeTimer.is_stopped():
		bowpct = 1.0
	
	var atk_red = atkpct
	var atk_green = 1 - atkpct
	if atk_green != 0:
		print(atk_green)
	var atk_blue = 0.0
	if attack_charged:
		atk_red = 1
		atk_green = 1
		atk_blue = 1
	$SwordCharge/ColorRect.color.r = atk_red
	$SwordCharge/ColorRect.color.g = atk_green
	$SwordCharge/ColorRect.color.b = atk_blue
	
	var bow_red = bowpct
	var bow_green = 1 - bowpct
	var bow_blue = 0.0
	if bow_charged:
		bow_red = 1
		bow_green = 1
		bow_blue = 1
	$BowCharge/ColorRect.color.r = bow_red
	$BowCharge/ColorRect.color.g = bow_green
	$BowCharge/ColorRect.color.b = bow_blue

func _set_health(_health):
	health = _health
	get_tree().get_root().get_node("Spatial/UI/HealthBar").value = health

func _set_level(_level):
	level = _level
	get_tree().get_root().get_node("Spatial/UI/XPBar").value = level
	
func _get_melee_enemies():
	return $AttackZone.get_overlapping_bodies()
	
func _get_ranged_enemies():
	return $ArrowZone.get_overlapping_bodies()

func _attack_single_enemy():
	var enemies = _get_melee_enemies()
	var closest_distance = INF
	var closest_enemy = null
	for enemy in enemies:
		var distance = self.global_transform.origin.distance_squared_to(enemy.global_transform.origin)
		if distance < closest_distance:
			closest_distance = distance
			closest_enemy = enemy
	if closest_enemy == null:
		# Nothing to do...
		return
	
	# Attack the enemy
	print("Attacking enemy: " + closest_enemy.to_string())
	var slashscn = load("res://objects/attacks/slash.tscn")
	var slash = slashscn.instance()
	self.get_parent().add_child(slash)
	slash.global_transform.origin = self.global_transform.origin
	slash.look_at(closest_enemy.global_transform.origin, Vector3(0, 1, 0))
	slash.rotate_object_local(Vector3(0,1,0), 3.14)

func _attack_all_enemies():
	# Hit 'em all
	var enemies = _get_melee_enemies()
	for enemy in enemies:
		print("Attacking enemy: " + enemy.to_string())
	var spinscn = load("res://objects/attacks/spin.tscn")
	var spin = spinscn.instance()
	spin.global_transform.origin = self.global_transform.origin
	self.get_parent().add_child(spin)

func _attack_enemy_with_bow():
	var enemies = _get_ranged_enemies()
	var furthest_distance = -INF
	var furthest_enemy = null
	for enemy in enemies:
		var distance = self.global_transform.origin.distance_squared_to(enemy.global_transform.origin)
		if distance > furthest_distance:
			furthest_distance = distance
			furthest_enemy = enemy
	if furthest_enemy == null:
		# Nothing to do...
		return
	
	var arrowscn = load("res://objects/attacks/arrow.tscn")
	var arrow = arrowscn.instance()
	self.get_parent().add_child(arrow)
	
	# Create a path for the arrow to follow
	var midpoint_x = (self.global_transform.origin.x + furthest_enemy.global_transform.origin.x) / 2
	var midpoint_z = (self.global_transform.origin.z + furthest_enemy.global_transform.origin.z) / 2
	var curve = Curve3D.new()
	curve.clear_points()
	curve.add_point(self.global_transform.origin)
	curve.add_point(Vector3(midpoint_x, furthest_enemy.global_transform.origin.y + 1, midpoint_z))
	curve.add_point(furthest_enemy.global_transform.origin)
	
	arrow.get_path().curve = curve
	arrow.global_transform.origin = self.global_transform.origin

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if event.pressed == true:
				# Sword pressed
				_attack_single_enemy()
				attack_charged = false
				$AttackChargeTimer.start()
			else:
				$AttackChargeTimer.stop()
				# Charged?
				if attack_charged == true:
					# spin attack
					_attack_all_enemies()
				else:
					# Not long enough
					pass
				attack_charged = false
		if event.button_index == 2:
			if event.pressed == true:
				# Start charging bow
				bow_charged = false
				$BowChargeTimer.start()
			else:
				# Stop charging bow
				$BowChargeTimer.stop()
				if bow_charged == true:
					# spin attack
					_attack_enemy_with_bow()
				else:
					# Not long enough
					pass
				bow_charged = false


func _on_AttackChargeTimer_timeout():
	attack_charged = true
	$AttackChargeTimer.stop()

func _on_BowChargeTimer_timeout():
	bow_charged = true
	$BowChargeTimer.stop()
