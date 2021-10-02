extends MeshInstance

export(float) var health = 100.0 setget _set_health
export(float) var level = 1 setget _set_level

func _set_health(_health):
	health = _health
	$Viewport/VBoxContainer/HP.text = str(health)
	$Viewport/VBoxContainer/HP.self_modulate = lerp(Color.red, Color.green, health/100.0)

func _set_level(_level):
	level = _level
	$Viewport/VBoxContainer/Level.text = str(level)
	
