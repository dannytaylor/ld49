extends MeshInstance

var attack_charged = false

export(float) var health = 100.0 setget _set_health
export(float) var level = 1 setget _set_level

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _set_health(_health):
	health = _health
	get_tree().get_root().get_node("Spatial/UI/HealthBar").value = health

func _set_level(_level):
	level = _level
	get_tree().get_root().get_node("Spatial/UI/XPBar").value = level
	
func _get_melee_enemies():
	return $AttackZone.get_overlapping_bodies()

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
	var slashscn = load("res://objects/effects/slash.tscn")
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
	var spinscn = load("res://objects/effects/spin.tscn")
	var spin = spinscn.instance()
	spin.global_transform.origin = self.global_transform.origin
	self.get_parent().add_child(spin)

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
		if event.button_index == 2:
			if event.pressed == true:
				# Do nothing on press
				pass
			else:
				# Arrow attack
				pass


func _on_AttackChargeTimer_timeout():
	attack_charged = true
	$AttackChargeTimer.stop()
