class_name Level_2f_Kitchen
extends BaseLevel

@onready var neutral_ghost: Neutral_GhostLibrary = $Y_Sort/Neutral_Ghost
@onready var enemy_eye_watcher: Enemy_EyeWatcher = $Y_Sort/Enemy_EyeWatcher
@onready var global_light: DirectionalLight2D = $Lights/GlobalLight
@onready var canvas_modulate: CanvasModulate = $Lights/CanvasModulate

func _ready() -> void:
	set_level_name("2nd Floor Kitchen")
	scene_path = "res://game_scenes/level_2f_kitchen.tscn"
	await init_level()
	
	player.light_main.visible = true

	if enemy_eye_watcher:
		enemy_eye_watcher.set_canvas(canvas_modulate)
	print("Level 2f Library ready")
	
