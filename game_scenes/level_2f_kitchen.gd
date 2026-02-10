class_name Level_2f_Kitchen
extends BaseLevel

@onready var neutral_ghost: Neutral_GhostLibrary = $Y_Sort/Neutral_Ghost
@onready var enemy_eye_watcher: Enemy_EyeWatcher = $Y_Sort/Enemy_EyeWatcher
@onready var global_light: DirectionalLight2D = $Lights/GlobalLight
@onready var canvas_modulate: CanvasModulate = $Lights/CanvasModulate

var npc_companion : BaseNPC

@onready var player_intro: Marker2D = $IntroMarkers/player_intro
@onready var companion_intro: Marker2D = $IntroMarkers/companion_intro
@onready var ghost_intro: Marker2D = $IntroMarkers/ghost_intro
@onready var eye_watcher_intro: Marker2D = $IntroMarkers/eye_watcher_intro
@onready var ghost_intro_2: Marker2D = $IntroMarkers/ghost_intro_2

var ghost_introdialogue_1 = [
	"You can hear me... can't you?",
	"Stay still.[Emphasis=1.0] ",
	"We're both searching for something... [Emphasis=0.325] I can tell."
]

var ghost_introdialogue_2 = [
	"That thing over there... it is watching this place.",
	"When its eyes open, [Emphasis=2.0]Don't move.",
]

func _ready() -> void:
	#debug
	SessionState.input_locked = false
	set_level_name("2nd Floor Kitchen")
	scene_path = "res://game_scenes/level_2f_kitchen.tscn"
	await init_level()
	
	player.light_main.visible = true

	if enemy_eye_watcher:
		enemy_eye_watcher.set_canvas(canvas_modulate)
	print("Level 2f Library ready")
	
	if SessionState.get_scene_data("2f_library_ghostfree", false):
		neutral_ghost.queue_free()
	if SessionState.get_global_data("eyewatcher_introduction", null):
		if enemy_eye_watcher:
			enemy_eye_watcher.set_canvas(canvas_modulate)
		return
	
	await play_intro_cutscene()
	
func play_intro_cutscene()->void:
	SessionState.input_locked = true
	game.start_cutscene()
	game.scene_manager.move_to(player_intro.global_position, player, 60)
	
	#Player w/ Companioon
	if game_difficulty != "hard":
		npc_companion = get_current_companion()
		game.scene_manager.move_to(companion_intro.global_position, npc_companion, 60)
	
		await game.scene_manager.wait_for([player])
		game.scene_manager.move_to(ghost_intro.global_position, neutral_ghost, 60)
		await game.vn_component_manager.get_dialogue(["We need to-"], "I", player.player_dialogue_sprite)
		player.show_emote("exclamation")
		
		await game.scene_manager.wait_for([neutral_ghost])
		npc_companion.face_target(neutral_ghost)
		player.face_target(neutral_ghost)
		
		await game.vn_component_manager.get_dialogue(ghost_introdialogue_1, neutral_ghost.npc_name, neutral_ghost.npc_dialogue_sprite)
		game.scene_manager.move_camera(player, eye_watcher_intro.global_position)

		await game.vn_component_manager.get_dialogue(ghost_introdialogue_2, neutral_ghost.npc_name, neutral_ghost.npc_dialogue_sprite)
		game.scene_manager.move_to(ghost_intro_2.global_position, neutral_ghost, 30)
		game.scene_manager.reset_camera(player)
		
		game.end_cutscene(true)
		SessionState.input_locked = false
		SessionState.set_global_data("eyewatcher_introduction", true)
		enemy_eye_watcher.set_canvas(canvas_modulate)
		return
		
	#Player without Companion
	await game.scene_manager.wait_for([player])
	game.scene_manager.move_to(ghost_intro.global_position, neutral_ghost, 60)
	await game.vn_component_manager.get_dialogue(["I need to get th-"], "I", player.player_dialogue_sprite)
	player.show_emote("exclamation")
	
	player.face_target(neutral_ghost)
	await game.scene_manager.wait_for([neutral_ghost])

	await game.vn_component_manager.get_dialogue(ghost_introdialogue_1, neutral_ghost.npc_name, neutral_ghost.npc_dialogue_sprite)
	game.scene_manager.move_camera(player, eye_watcher_intro.global_position)

	await game.vn_component_manager.get_dialogue(ghost_introdialogue_2, neutral_ghost.npc_name, neutral_ghost.npc_dialogue_sprite)
	game.scene_manager.move_to(ghost_intro_2.global_position, neutral_ghost, 30)
	game.scene_manager.reset_camera(player)
	
	game.end_cutscene(true)
	SessionState.input_locked = false
	SessionState.set_global_data("eyewatcher_introduction", true)
	enemy_eye_watcher.set_canvas(canvas_modulate)
