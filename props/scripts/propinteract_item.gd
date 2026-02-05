extends Node2D
class_name PropInteract_Item

static var active_prop: PropInteract_Item = null

signal has_interacted
var prop_interaction_ui = preload("uid://jf6by2vn3ay3").instantiate()

const sound_interact_default = preload("uid://cmdr63ctw15h7")
const sound_interact_book = preload("uid://d1usegrl8kyo1")

var player_nearby = false

signal player_enter_proparea
signal player_leave_proparea

signal interaction_allowed
signal interaction_failed

@export_category("Dialogue")
@export var prop_interact_dialogue = []
@export_category("Inventory")
@export var itemid_to_add = ""
@export var item_to_add = ""
@export var itemamount_to_add = 1
@export_category("Interaction")
@export var interaction_options = ["take", "leave"]
@export var remove_when_taken : bool = false
@export_category("")
@export_enum("default", "book") var prop_sound : String = "default"
@export_category("Conditions")
@export var debug : bool = false
@export var unlock_flag : String = ""
@export var can_interact : bool = true
@export var can_interact_multiple_times: bool = false
@export var required_item_id: String = ""
@export var required_item_amount : int = 1
@export var required_item_dialogue : Array[String] = []
@export var prop_required_data : String = ""

var prop_interaction_options = {
	"use" : {
		"choice": "Use",
		"choice_id": "use"
	},
	"take": {
		"choice": "Take", 
		"choice_id": "take"
	},
	 "leave": {
		"choice": "Leave",
		"choice_id": "leave"
	},
	 "destroy": {
		"choice": "Destroy ",
		"choice_id": "destroy"
	}
}

var prop_interaction_sounds = {
	"default": sound_interact_default,
	"book": sound_interact_book
}
var interact_done = false
var is_interacting = false

func _ready() -> void:
	if get_parent().has_node("Area2D"):
		var area_2d = get_parent().get_node_or_null("Area2D")
		area_2d.area_entered.connect(_on_area_entered)
		area_2d.area_exited.connect(_on_area_exited)
		player_enter_proparea.connect(interact)
		#player_leave_proparea.connect()
	
func _on_area_entered(area) -> void:
	if area.name == "Player_InteractionArea":
		print("AREA ENTERED: ", prop_required_data)
		player_nearby = true
		PropInteract_Item.active_prop = self

func _on_area_exited(area) -> void:
	if area.name == "Player_InteractionArea":
		print("AREA EXITED: ", prop_required_data)
		player_nearby = false
		if PropInteract_Item.active_prop == self:
			PropInteract_Item.active_prop = null


func _process(_delta):
	if PropInteract_Item.active_prop == self and Input.is_action_just_pressed("Interact"):
		if interact_done and not can_interact_multiple_times:
			return
		is_interacting = true
		await interact()
		is_interacting = false
	
func interact() -> void:
	if !can_interact:
		return
		
	if is_interacting:
		return
	var prop_audio_player := AudioStreamPlayer.new()
	add_child(prop_audio_player)  # Add it so Godot can play it
	
	prop_audio_player.stream = prop_interaction_sounds.get(prop_sound, sound_interact_default)
	prop_audio_player.pitch_scale = 1.25
	prop_audio_player.volume_db = -2.0
	prop_audio_player.play()
	
	var game = get_tree().get_root().get_node("Game") as Game
	if prop_required_data:
		if !SessionState.get_scene_data(prop_required_data, false):
			print("You need to the condition: ", prop_required_data)
			return
			
	if required_item_id != "" and !InventoryManager.has_required_item(required_item_id, required_item_amount):
		await game.vn_component_manager.get_narration(required_item_dialogue)
		print("You need ", required_item_id, " to interact!")
		return
	elif required_item_id != "" and InventoryManager.has_required_item(required_item_id, required_item_amount):
		InventoryManager.remove_item(required_item_id, required_item_amount)
		if debug:
			SessionState.set_global_data("debug", true)
			
	if !interaction_options.is_empty():
		var options = []
		for option in interaction_options:
			if prop_interaction_options.has(option):
				options.append(prop_interaction_options[option])
		var choice = await game.vn_component_manager.get_choices(options)
		
		match choice:
			"take":
				await game.vn_component_manager.get_narration(["You obtain the " + item_to_add])
				
				if remove_when_taken:
					queue_free()
			"leave":
				return
				
	if prop_interact_dialogue.size() > 0:
		game.vn_component_manager.get_narration(prop_interact_dialogue)
		await game.vn_component_manager.narration_finished
		
	#example "item_key", "Key"
	if itemid_to_add != "" and item_to_add != "":
		InventoryManager.add_item(itemid_to_add, item_to_add, itemamount_to_add, interaction_options)
	
	interaction_allowed.emit()
	interact_done = true
	has_interacted.emit(true)
