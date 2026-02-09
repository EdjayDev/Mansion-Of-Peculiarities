extends BaseEnemy
class_name enemy_shadow

var file_path = "res://npc/Enemy_Shadow.tscn"

var dialogue = [
	"...",
]

var dialogue_exploration = [
	".."
]

var choices = [
	{"choice": "...", "choice_id" : "do_nothing"}
]

func _ready():
	initialize_npc()
	set_npc_group("npc")
	set_npc_group("enemy")
	
func interact():
	pass
	
