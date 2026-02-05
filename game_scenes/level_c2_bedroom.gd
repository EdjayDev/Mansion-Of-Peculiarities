extends BaseLevel
class_name Level_C2_Bedroom

func _ready() -> void:
	set_level_name("Bedroom")
	scene_path = "res://game_scenes/level_c2_bedroom.tscn"
	await init_level()
