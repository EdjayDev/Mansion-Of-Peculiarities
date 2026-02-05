extends BaseLevel
class_name Level_C2_Emptyroom

func _ready() -> void:
	set_level_name("Emptyroom")
	scene_path = "res://game_scenes/level_c2_emptyroom.tscn"
	await init_level()
