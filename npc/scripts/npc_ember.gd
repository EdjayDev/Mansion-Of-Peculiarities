class_name npc_ember
extends BaseNPC

@onready var npc_area_2d: Area2D = $Area2D
@onready var sprite_2d_dialogue_sprite: Sprite2D = $"Sprite2D-DialogueSprite"

@export var npc_name_ : String
@export var inCutscene_ : bool
@export var npc_animation_ : String
@export var is_following_player_: bool = false

@onready var npc_navigation_agent: NavigationAgent2D = $NavigationAgent2D


var file_path = "res://npc/NPC_Ember.tscn"

var dialogue = [
	"These books are weird!",
	"Some are scribbled all over and only a few of them are still readable.",
	"But,[Emphasis=1.0] I'd say as a decoration they look pretty neat.",
	"..."
]

var dialogue_exploration = [
	"."
]

var choices = [
	{"choice": "...", "choice_id" : "do_nothing"}
]

func _ready():
	initialize_npc()
	
func interact():
	if SessionState.get_global_data("continue_exploration", false):
		set_npcdialogue(dialogue_exploration)
		
	face_target(player_get)
	print("Talking to NPC...")
	print("Ember is in cutscene? ", in_cutscene)
	var game = get_tree().get_root().get_node("Game") as Game
	game.vn_component_manager.get_dialogue(npc_dialogue, npc_name, npc_dialogue_sprite)
	await game.vn_component_manager.dialogue_finished
	
	#choice_id = await game.vn_component_manager.get_choices(npc_choices)
	forced_animation = false

func initialize_npc()->void:
	add_to_group("npc")
	
	set_npc_file_path(file_path)
	set_npc_id(npc_name_.to_lower())
	set_npc_name(npc_name_)
	set_npcdialogue(dialogue)
	set_npcchoices(choices)	
	set_npc_dialogue_sprite(sprite_2d_dialogue_sprite)
	set_area2d(npc_area_2d)
	set_navigation_agent(npc_navigation_agent)
	character_in_cutscene_handler()
	sync_state()
