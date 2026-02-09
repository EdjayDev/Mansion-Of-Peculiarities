extends BaseLevel
class_name Level_2f


@onready var intro_player: Marker2D = $Intro_PathMarkers/intro_player
@onready var intro_ember: Marker2D = $Intro_PathMarkers/intro_ember
@onready var intro_luke: Marker2D = $Intro_PathMarkers/intro_luke

@onready var intro_player_2: Marker2D = $Intro_PathMarkers/intro_player2
@onready var intro_ember_2: Marker2D = $Intro_PathMarkers/intro_ember2
@onready var intro_luke_2: Marker2D = $Intro_PathMarkers/intro_luke2

@onready var outro_exit: Marker2D = $Intro_PathMarkers/outro_exit
@onready var shadow: enemy_shadow = $Y_Sort/Enemy_Shadow
@onready var shadow_mark: Marker2D = $Intro_PathMarkers/shadow_mark

@onready var dark_swarm: Shadow_Swarm = $Dark_Swarm

@onready var new_path_runaway: Node2D = $NewPath_Runaway
@onready var remove_path: Node2D = $NewPath_Runaway/Remove_Path
@onready var new_path: Node2D = $NewPath_Runaway/New_Path

@onready var ghost_exit: Marker2D = $Intro_PathMarkers/ghost_exit

var dialogue_facingluke = [
	"I think we lost that thing..."
]

var dialogue_facingember = [
	""
]

var choices = [
	{"choice": "Run Away", "choice_id": "hard"},
	{"choice": "Grab Luke", "choice_id": "easy"},
	{"choice": "Grab Ember", "choice_id": "medium"}
]

func _ready() -> void:
	set_level_name("2nd Floor")
	scene_path = "res://game_scenes/level_2f.tscn"
	await init_level()
	player.light_ambient.texture_scale = 1.0
	player.light_main.texture_scale = 0.25
	print("Level 2f ready")
	await intro_cutscene()
	
func intro_cutscene() -> void:
	var luke = get_npc_by_id("luke")
	var ember = get_npc_by_id("ember")
	
	#if the group faced the shadow
	if SessionState.get_global_data("faced_shadow", false):
		remove_path.queue_free()
		new_path.visible = true
		
		SessionState.input_locked = true
		await get_tree().process_frame
		game.start_cutscene()
		
		game.scene_manager.move_to(intro_player_2.global_position, player, 70)
		game.scene_manager.move_to(intro_luke_2.global_position, luke, 70)
		game.scene_manager.move_to(intro_ember_2.global_position, ember, 70)
		await game.scene_manager.wait_for([player, luke, ember])
		
		luke.face_target(player)
		player.face_target(luke)
		ember.face_target(player)
		await game.vn_component_manager.get_dialogue(dialogue_facingluke, "I", player.player_dialogue_sprite)
		player.face_target(ember)

		await get_tree().create_timer(2.5).timeout
		
		game.scene_manager.move_to(shadow_mark.global_position, shadow, 20)
		player.face_target(shadow)
		ember.face_target(shadow)
		luke.face_target(shadow)
		dark_swarm.dark_swarm()
		var difficulty = await game.vn_component_manager.get_choices(choices)
		match difficulty:
			"easy":
				SessionState.remove_companion("ember")
				ember.is_following_player = false
				await game.vn_component_manager.get_dialogue(["luke come with me!"], "I", player.player_dialogue_sprite)
				game.scene_manager.move_to(luke.global_position, player, 60)
				await game.scene_manager.wait_for([player])
				game.scene_manager.move_to(outro_exit.global_position, player, 100)
				game.scene_manager.move_to(outro_exit.global_position, luke, 95)
				game.scene_manager.move_to(ghost_exit.global_position, ember, 95)
				await game.scene_manager.wait_for([player,luke])
				player.visible = false
				luke.visible = false
				await game.scene_manager.wait_time(2.0)
			"medium":
				SessionState.remove_companion("luke")
				await game.vn_component_manager.get_dialogue(["ember come with me!"], "I", player.player_dialogue_sprite)
				game.scene_manager.move_to(ember.global_position, player, 60)
				await game.scene_manager.wait_for([player])
				game.scene_manager.move_to(outro_exit.global_position, player, 100)
				game.scene_manager.move_to(outro_exit.global_position, ember, 95)
				game.scene_manager.move_to(ghost_exit.global_position, luke, 85)
				luke.is_following_player = false
				await game.scene_manager.wait_for([player,ember])
				player.visible = false
				ember.visible = false
				await game.scene_manager.wait_time(2.0)
			"hard":
				SessionState.clear_companion()
				await game.vn_component_manager.get_dialogue(["..."], "I", player.player_dialogue_sprite)
				game.scene_manager.move_to(outro_exit.global_position, player, 100)
				game.scene_manager.move_to(ghost_exit.global_position, ember, 115)
				game.scene_manager.move_to(ghost_exit.global_position, luke, 95)
				ember.is_following_player = false
				luke.is_following_player = false
				await game.scene_manager.wait_for([player])
				player.visible = false
				await game.scene_manager.wait_time(2.0)

		SessionState.set_difficulty(difficulty)
		SessionState.set_scene_data("IntroCutscene_2f_end", true)
		game.end_cutscene(true)
		SessionState.input_locked = false
		return
	
	#If Intro Cutscene for this level has been finished
	if SessionState.get_scene_data("IntroCutscene_2f", false):
		luke.global_position = SessionState.get_npc_position(luke.npc_id, LEVEL_NAME)
		ember.global_position = SessionState.get_npc_position(ember.npc_id, LEVEL_NAME)
		return
		
	#Intro Cutscenea
	SessionState.input_locked = true
	await get_tree().process_frame
	game.start_cutscene()
	
	#cutscene flow
	game.scene_manager.move_to(intro_player.global_position, player, 20)
	game.scene_manager.move_to(intro_luke.global_position, luke, 20)
	game.scene_manager.move_to(intro_ember.global_position, ember, 20)
	
	await game.scene_manager.wait_for([luke,ember])
	
	game.end_cutscene(true)
	SessionState.input_locked = false
	SessionState.set_scene_data("IntroCutscene_2f", true)
