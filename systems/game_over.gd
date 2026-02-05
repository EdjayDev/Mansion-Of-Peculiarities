extends Control
class_name Game_Over

var game : Game

@onready var game_over_audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var text_game_over: RichTextLabel = $text_GameOver
@onready var text_flavortext: RichTextLabel = $text_flavortext

@onready var flow_container: FlowContainer = $FlowContainer
@onready var button_retry: Button = $FlowContainer/button_retry
@onready var button_quit: Button = $FlowContainer/button_quit


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	game = get_tree().get_root().get_node("Game") as Game
	flow_container.visible = false
	button_retry.pressed.connect(game_retry)
	button_quit.pressed.connect(game_quit)
	
func game_over_screen(text : String = "GAME OVER", flavor_text : String = "", player : Player = null)->void:
	SessionState.input_locked = true
	await game.screen_effect_ui.set_effect("fade_out", 1)
	if player:
		player.global_position = SessionState.temp_player_position
	game_over_audio.volume_db = 1.0
	game_over_audio.pitch_scale = 1.25
	game_over_audio.play()
	text_game_over.text = text
	text_flavortext.text = flavor_text
	
	animation_player.play("show_text", -1, 0.5)
	get_tree().paused = true
	await animation_player.animation_changed
	pass

func reset_game_over()->void:
	animation_player.play("RESET")
	game_over_audio.stop()
	
func game_retry()->void:
	get_tree().paused = false
	SessionState.input_locked = false
	SessionState.global_data = SessionState.temp_global_data
	
	await game.load_level(SessionState.temp_level_path, SessionState.temp_spawn_marker, SessionState.temp_companion_marker)
	reset_game_over()
	
func game_quit()->void:
	SessionState.reset_session()
	get_tree().change_scene_to_file("res://systems/main_menu_ui.tscn")
