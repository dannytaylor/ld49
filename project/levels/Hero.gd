extends MeshInstance

var attack_charged = false
var bow_charged = false

var captureMouse = false

export(float) var health = 25.0 setget _set_health
export(float) var level = 0 setget _set_level

var num_clears = 0 setget _set_numclears

var unlock_level = 0
var extra_damage = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	_check_unlocks()

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
	var atk_blue = 0.0
	if attack_charged or unlock_level < 2:
		atk_red = 0.0
		atk_green = 0.0
		atk_blue = 0.0
	$SwordCharge/ColorRect.color.r = atk_red
	$SwordCharge/ColorRect.color.g = atk_green
	$SwordCharge/ColorRect.color.b = atk_blue
	
	var bow_red = bowpct
	var bow_green = 1 - bowpct
	var bow_blue = 0.0
	if bow_charged:
		bow_red = 0.0
		bow_green = 0.0
		bow_blue = 0.0
	$BowCharge/ColorRect.color.r = bow_red
	$BowCharge/ColorRect.color.g = bow_green
	$BowCharge/ColorRect.color.b = bow_blue

func _set_health(_health):
	var diff = health - _health
	health = _health
	get_tree().get_root().get_node("Spatial/UI/HealthBar").value = health
	var notifyscene = load("res://objects/Player/notify.tscn")
	var hurt = notifyscene.instance()
	hurt.set_modulate(Color("bd1f3f"))
	hurt.set_label("-" + String(diff))
	self.add_child(hurt)
	
	if health <= 0:
		print("LOSER")
		get_tree().get_root().get_node("Spatial/UI/EndCard/EndText").text = 'YOU DIED'
		get_tree().get_root().get_node("Spatial/UI/EndCard").visible = true

func _set_level(_level):
	level = _level
	get_tree().get_root().get_node("Spatial/UI/XPBar").value = level
	get_tree().get_root().get_node("Spatial/UI/XPBar/Label").text = str(unlock_level+1)
	
	var notifyscene = load("res://objects/Player/notify.tscn")
	var help = notifyscene.instance()
	help.set_modulate(Color("158968"))
	help.set_label("+1")
	self.add_child(help)
	
	if level == 6:
		unlock_level += 1
		_check_unlocks()
		_set_level(1)

func _set_numclears(_numclears):
	num_clears = _numclears
	if num_clears == 3:
		# win!
		print("winner")
		get_tree().get_root().get_node("Spatial/UI/EndCard/EndText").text = 'YOU WON!'
		get_tree().get_root().get_node("Spatial/UI/EndCard").visible = true

func _check_unlocks():
	if unlock_level >= 0:
		$BowCharge.visible = false
		$SwordCharge.visible = true
		# Do nothing
		pass
	if unlock_level >= 1:
		# Bow and arrow
		$BowCharge.visible = true
		pass
	if unlock_level >= 2:
		# Spin
		pass
	if unlock_level >= 3:
		# Extra sword damage?
		extra_damage = unlock_level - 2
		pass
	

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

	var use_poke = true
	if randi() % 2:
		use_poke = false 
	var slashscn = null
	if use_poke:
		slashscn = load("res://objects/attacks/poke.tscn")
	else:
		slashscn = load("res://objects/attacks/slash.tscn")
	var slash = slashscn.instance()
	$HeroMesh/AnimationPlayer.stop()
	$HeroMesh/AnimationPlayer.play("attack",-1,2)
	$HitSound.play()
	self.get_parent().add_child(slash)
	slash.global_transform.origin = self.global_transform.origin
	slash.look_at(closest_enemy.global_transform.origin, Vector3(0, 1, 0))
	slash.rotate_object_local(Vector3(0,1,0), 3.14)
	
	closest_enemy.get_hit(1 + extra_damage)

func _attack_all_enemies():
	if unlock_level < 2:
		return
	# Hit 'em all
	var enemies = _get_melee_enemies()
	for enemy in enemies:
		enemy.get_hit(3 + extra_damage)
	var spinscn = load("res://objects/attacks/spin.tscn")
	var spin = spinscn.instance()
	spin.global_transform.origin = self.global_transform.origin
	self.get_parent().add_child(spin)
	$HeroMesh/AnimationPlayer.play("spin",-1,2)
	$HitSound.play()

func get_hit(dmg):
	self.health -= dmg

func _attack_enemy_with_bow():
	if unlock_level < 1:
		return
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
	arrow.target = furthest_enemy

func _input(event):
	if event is InputEventMouseButton:
		if not captureMouse:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			captureMouse = true
			
		if event.button_index == 1:
			if event.pressed == true:
				if attack_charged:
					_attack_all_enemies()
				else:
					_attack_single_enemy()
				attack_charged = false
				$AttackChargeTimer.stop()
				$AttackChargeTimer.start()
		if event.button_index == 2:
			if event.pressed == true:
				if bow_charged:
					_attack_enemy_with_bow()
					bow_charged = false
					$BowChargeTimer.stop()
					$BowChargeTimer.start()
	elif event is InputEventKey and event.scancode == KEY_R and (health <= 0 or num_clears==3):
		get_tree().reload_current_scene()

func _on_AttackChargeTimer_timeout():
	attack_charged = true
	$AttackChargeTimer.stop()

func _on_BowChargeTimer_timeout():
	bow_charged = true
	$BowChargeTimer.stop()
