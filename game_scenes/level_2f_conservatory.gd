class_name Level_2f_Conservatory
extends BaseLevel

@onready var neutral_ghost: Neutral_GhostLibrary = $Y_Sort/Neutral_Ghost
@onready var enemy_eye_watcher: Enemy_EyeWatcher = $Y_Sort/Enemy_EyeWatcher
@onready var global_light: DirectionalLight2D = $Lights/GlobalLight
@onready var canvas_modulate: CanvasModulate = $Lights/CanvasModulate

func _ready() -> void:
	set_level_name("2nd Floor Conservatory")
	scene_path = "res://game_scenes/level_2f_conservatory.tscn"
	await init_level()

	if enemy_eye_watcher:
		enemy_eye_watcher.set_canvas(canvas_modulate)
	print("Level 2f Arcade ready")
