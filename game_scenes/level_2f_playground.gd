class_name Level_2f_Playground
extends BaseLevel

func _ready() -> void:
	set_level_name("2nd Floor Small Room")
	scene_path = "res://game_scenes/level_2f_playground.tscn"

	await init_level()
	print("Level_2f_Playground ready")
	game.set_bgmusic_setting(-10.0, 0.9)
	
	# Check if level visited before, and if player got the door keys depending on difficulty
	var visited : bool = SessionState.get_scene_data("visited_before", false)
	
	if not visited:
		SessionState.set_scene_data("visited_before", true)
		show_room_intro_emote()
		
func _process(_delta: float) -> void:
	pass

func show_room_intro_emote() -> void:
	if player:
		player.show_emote("exclamation")
