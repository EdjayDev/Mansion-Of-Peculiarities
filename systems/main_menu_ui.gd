extends CanvasLayer
class_name MainMenu_UI

const GAME = preload("uid://ceow7wr54ok86")

@onready var save_system_ui: SaveSystem_UI = $CanvasLayer/Control/btn_continue/SaveSystem_UI
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	audio_stream_player_2d.play()
	save_system_ui.request_load_game.connect(_on_request_load_game)

func _on_new_game_pressed() -> void:
	SessionState.reset_session()
	get_tree().change_scene_to_packed(GAME)

func _on_continue_pressed() -> void:
	save_system_ui.visible = true

func _on_quit_pressed() -> void:
	get_tree().quit()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("GameMenu") and save_system_ui.visible:
		save_system_ui.visible = false

func _on_request_load_game(slot: int, level_path: String) -> void:
	print("[MainMenu_UI] Loading Game scene, level:", level_path)
	
	# Save requested level in SessionState
	SessionState.requested_level_path = level_path
	SessionState.requested_spawn_id = SaveSystem.get_world_data(slot).get("spawn_id", "start")

	# Load Game scene
	get_tree().change_scene_to_packed(GAME)
