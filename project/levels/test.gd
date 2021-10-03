extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	switch_to_floor(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	check_travel(delta)

func check_travel(delta):
	var base = travel_data["base"]
	if base["traveling"] == true:
		base["time"] += delta
		if base["time"] >= base["distance"]:
			print("Travel to Base")
			base["traveling"] = false
			switch_to_floor(0)
	var cave = travel_data["cave"]
	if cave["traveling"] == true:
		cave["time"] += delta
		if cave["time"] >= cave["distance"]:
			print("Travel to Cave")
			cave["traveling"] = false
			switch_to_floor(-1)
	var sky = travel_data["sky"]
	if sky["traveling"] == true:
		sky["time"] += delta
		if sky["time"] >= sky["distance"]:
			print("Travel to Sky")
			sky["traveling"] = false
			switch_to_floor(1)
			
func switch_to_floor(new_floor):
	$World/Board_level_base.visible = false
	$World/Board_level_cave.visible = false
	$World/Board_level_sky.visible = false
	$World/Board_level_base.set_collision(false)
	$World/Board_level_cave.set_collision(false)
	$World/Board_level_sky.set_collision(false)
	if new_floor == 0:
		$World/Board_level_base.visible = true
		$World/Board_level_base.set_collision(true)
	if new_floor == -1:
		$World/Board_level_cave.visible = true
		$World/Board_level_cave.set_collision(true)
	if new_floor == 1:
		$World/Board_level_sky.visible = true
		$World/Board_level_sky.set_collision(true)
		

var travel_data = {
	"base": {"traveling": false, "distance": 3, "time": 0},
	"cave": {"traveling": false, "distance": 3, "time": 0},
	"sky": {"traveling": false, "distance": 3, "time": 0}
}

func _on_Cave_body_entered(body):
	if body == $Hero:
		travel_data["cave"]["traveling"] = true
		travel_data["cave"]["time"] = 0
	
func _on_Cave_body_exited(body):
	if body == $Hero:
		travel_data["cave"]["traveling"] = false
		travel_data["cave"]["time"] = 0
