extends Node
class_name Level_Randomizer

@export var level_list = [
	"classroom",
	"bedroom",
	"emptyroom",
	"flowers",
	"graffiti",
	"food",
	"bloodyroom",
	"toys",
	"theater",
	"axe",
	"hallwaycorpse",
	"mirrors",
	"museum",
	"dressingroom"
] 

func pick_randomlevel()->String:
	var random_level = level_list.pick_random()
	return "res://gamescenes/level_c2_%s.tscn" % random_level
	
