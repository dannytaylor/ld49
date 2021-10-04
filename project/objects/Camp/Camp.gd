extends Spatial

export(int) var total_enemies = 10
export(int) var max_simul = 2
export(float) var spawn_delay = 30
export(String) var camp_name = "NULL_CAMP"
export(String, "goblin", "hobgoblin", "ogre") var enemy_type
export(NodePath) var spawn_parent
export(NodePath) var hero

var spawns = []
var monster_scene = null
var rng = RandomNumberGenerator.new()

func _get_rng_val(minval, maxval):
	rng.randomize()
	var rngval = rng.randf_range(minval, maxval)
	return rngval

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	monster_scene = load("res://objects/Enemy/Enemy.tscn")
	# First spawn is either a quarter of the duration or 4/5ths at most
	$spawn_timer.wait_time = 1 + _get_rng_val(0.25, 1)
	$spawn_timer.start()

func notify_spawn_death(monster):
	var mpath = monster.get_path()
	if spawns.has(mpath):
		spawns.erase(mpath)
		self.remove_child(monster)

func register_spawn_active(monster):
	var mpath = monster.get_path()
	spawns.append(mpath)

func _on_spawn_timer_timeout():
	var spawn_time = spawn_delay + _get_rng_val(spawn_delay * (2.0 / 5.0) * -1.0, spawn_delay * (1.0 / 5.0))
	$spawn_timer.wait_time = spawn_time
	$spawn_timer.start()
	
	# Should we spawn anything?
	if spawns.size() >= max_simul:
		return
	
	# Spawn something!
	var new_monster = null
	new_monster = monster_scene.instance()
	new_monster.global_transform  = $spawn_location.global_transform 
	if enemy_type == "goblin":
		# Do nothing extra
		pass
	if enemy_type == "hobgoblin":
		# Ranged enemy
		new_monster.attack_range = 7.0
		new_monster.attack_time = 4.0
		new_monster.attack_backswing = 7.0
		new_monster.attack_type = "ranged"
		new_monster.scale *= 1.20
	if enemy_type == "ogre":
		new_monster.attack_time = 1.5
		new_monster.attack_backswing = 2
		new_monster.armor = 0
		new_monster.health = 4
		new_monster.scale *= 1.50
	get_node(spawn_parent).add_child(new_monster)
	new_monster.spawner = self
	new_monster.register_spawn()
	new_monster.hero_obj = get_node(hero)
