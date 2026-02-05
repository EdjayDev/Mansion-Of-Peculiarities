extends BaseNPC
class_name Neutral_GhostLibrary

@onready var npc_area_2d: Area2D = $Area2D
@onready var sprite_2d_dialogue_sprite: Sprite2D = $"Sprite2D-DialogueSprite"

@export_category("Item Fields")
@export var cherished_items : Array = []
@export var gift_item_id = ""
@export var gift_item = ""

@export_category("Item Drops")
@onready var ghost_drop: PropInteract_Item = $ghost_drop as PropInteract_Item
@export var ghost_drop_required_data : String
@export var ghost_drop_dialogue : Array[String]= []


@export_category("NPC_State")
@export var npc_name_ : String
@export var inCutscene_ : bool
@export var npc_animation_ : String
@export var is_following_player_: bool = false

@onready var npc_navigation_agent: NavigationAgent2D = $NavigationAgent2D

var file_path = "res://npc/Neutral_Ghost.tscn"

var dialogue = [
	"This place still remembers me",
	"It must be somewhere...",
]

var random_dialogue = [
	["The silence keeps correcting my breathing."],
	["I cut the endings because they hurt less that way."],
	["Someone always stood where I should have been."],
	["The pauses were safer than the words. I hid there."],
	["I don’t remember my voice anymore. Only the shape it made."],
	["Something rewrites me when I repeat myself."],
	["Nothing I made survived me. That feels deliberate."],
	["I stayed awake rewriting the same moment until it stopped breathing."],
	["I taught silence how to speak. It learned too well."],
	["If I stop arranging things, everything collapses. Including me."]
]

var dialogue_gratitude = [
	"...Yes.",
	"I remember it now.",
	"I was afraid to leave without it.",
	"Thank you… for seeing me."
]

var dialogue_hate = [
	"That's not it..."
]
var dialogue_exploration = [
	".."
]

var choices = [
	{"choice": "...", "choice_id" : "do_nothing"}
]

var item_choices = [
	{"choice": "Give Item", "choice_id" : "give_item"},
	{"choice": "...", "choice_id" : "do_nothing"}
]

func _ready():
	ghost_drop.visible = false
	ghost_drop.prop_interact_dialogue = ghost_drop_dialogue
	ghost_drop.prop_required_data = ghost_drop_required_data
	initialize_npc()
	
func initialize_npc()->void:
	add_to_group("neutral")
	
	set_npc_file_path(file_path)
	set_npc_id(npc_name_.to_lower())
	set_npc_name(npc_name_)
	set_npcdialogue(dialogue)
	set_npcchoices(choices)	
	set_npc_dialogue_sprite(sprite_2d_dialogue_sprite)
	set_area2d(npc_area_2d)
	set_navigation_agent(npc_navigation_agent)
	character_in_cutscene_handler()

func interact()->void:
	face_target(player_get)
	print("Player Get: ", player_get)
	var game = get_tree().get_root().get_node("Game") as Game
			
	if SessionState.get_scene_data("interacted_ghost", false):
		set_npcdialogue(random_dialogue[randi_range(0, random_dialogue.size()-1)])
		if InventoryManager.equipped_item:
			var choice = await game.vn_component_manager.get_choices(item_choices)
			if choice == "give_item":
				print("equipped item: ", InventoryManager.equipped_item)
				give_cherish_item(InventoryManager.equipped_item)
				return
			else:
				return
	
	await game.vn_component_manager.get_dialogue(npc_dialogue, "?", npc_dialogue_sprite)
	SessionState.set_scene_data("interacted_ghost", true)
	
func give_cherish_item(item : String)->void:
	var game = get_tree().get_root().get_node("Game") as Game
	if item in cherished_items:
		print("Ghost Entertain")
		game.start_cutscene()
		
		SessionState.input_locked = true
		face_target(player_get)
		await game.vn_component_manager.get_dialogue(dialogue_gratitude, "?", npc_dialogue_sprite)
		
		game.end_cutscene(true)
		SessionState.input_locked = false
		SessionState.set_scene_data(ghost_drop_required_data, true)
		await play_custom_animation("ghost_fading")
		area_2d.process_mode = Node.PROCESS_MODE_DISABLED
		
	else:
		await game.vn_component_manager.get_dialogue(dialogue_hate, "?", npc_dialogue_sprite)
		pass	
	pass
