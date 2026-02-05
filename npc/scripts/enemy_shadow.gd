extends BaseEnemy
class_name enemy_shadow

@onready var npc_area_2d: Area2D = $Area2D
@onready var sprite_2d_dialogue_sprite: Sprite2D = $"Sprite2D-DialogueSprite"

@export var npc_name_ : String
@export var inCutscene_ : bool
@export var npc_animation_ : String
@export var is_following_player_: bool = false

@onready var npc_navigation_agent: NavigationAgent2D = $NavigationAgent2D

var file_path = "res://npc/Enemy_Shadow.tscn"

var dialogue = [
	"...",
]

var dialogue_exploration = [
	".."
]

var choices = [
	{"choice": "...", "choice_id" : "do_nothing"}
]

func _ready():
	initialize_npc()
	
func interact():
	pass

func initialize_npc()->void:
	add_to_group("npc")
	add_to_group("enemy")
	
	set_npc_file_path(file_path)
	set_npc_id(npc_name_.to_lower())
	set_npc_name(npc_name_)
	set_npcdialogue(dialogue)
	set_npcchoices(choices)	
	set_npc_dialogue_sprite(sprite_2d_dialogue_sprite)
	set_area2d(npc_area_2d)
	set_navigation_agent(npc_navigation_agent)
	character_in_cutscene_handler()
	
