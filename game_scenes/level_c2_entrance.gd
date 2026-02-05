extends BaseLevel
class_name Level_C2_Entrance

func _ready() -> void:
	set_level_name("Garden")
	scene_path = "res://game_scenes/level_c2_entrance.tscn"
	await init_level()
