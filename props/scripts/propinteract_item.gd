extends Node2D
class_name PropInteract_Item

var game : Game = null

static var active_prop: PropInteract_Item = null

var prop_interaction_ui = preload("uid://jf6by2vn3ay3").instantiate()

const sound_interact_default = preload("uid://cmdr63ctw15h7")
const sound_interact_book = preload("uid://d1usegrl8kyo1")
const sound_interact_lock = preload("uid://c5msbsg5r7bmb")

var player_nearby = false

signal interaction_allowed
var interaction_successful = false

@export_category("Dialogue")
@export var prop_interact_dialogue = []
@export var prop_swap_interact_dialogue = []
@export var prop_interact_successful_dialogue = []
@export var prop_interact_uncessful_dialogue = []
@export_category("Inventory")
@export var stop_adding_item : bool = true
@export var difficulty_based : bool = false
@export var item_increment : int = 0
@export var itemid_to_add = ""
@export var item_to_add = ""
@export var itemamount_to_add = 1
@export_category("Interaction")
@export var animation_name : Array[String] = []
@export var animate_prop : bool = false
var animate_player : AnimationPlayer = null
@export var interaction_options = ["take", "leave"]
@export var remove_after : bool = false
@export_category("Prop Interaction Audio")
@export var play_interact_audio : bool = false
@export_enum("default", "book", "lock") var interact_successful_sound : String = "default"
@export_enum("default", "book", "lock") var interact_failed_sound : String = "default"
@export_category("Conditions")
@export var debug : bool = false
@export var unlock_flag : String = ""
@export var can_interact : bool = true
@export var can_interact_multiple_times: bool = false
@export var required_item_id: String = ""
@export var required_item_amount : int = 1
@export var required_item_dialogue : Array[String] = []
@export var prop_required_data : String = ""

var prop_interaction_sounds = {
	"default": sound_interact_default,
	"book": sound_interact_book,
	"lock": sound_interact_lock
}

var interact_done = false
var is_interacting = false

func _ready() -> void:
	game = get_tree().get_root().get_node("Game") as Game
	set_process_unhandled_input(false) 
	
	# Load saved state
	if prop_required_data != "":
		var saved_state = SessionState.get_scene_data(prop_required_data)
		if saved_state == true:
			interact_done = true
			required_item_id = ""
			required_item_dialogue = []  

			if prop_swap_interact_dialogue:
				prop_interact_dialogue = prop_swap_interact_dialogue
				
	if get_parent().has_node("Area2D"):
		var area_2d = get_parent().get_node_or_null("Area2D")
		area_2d.area_entered.connect(_on_area_entered)
		area_2d.area_exited.connect(_on_area_exited)
	if animate_prop:
		for child in get_parent().get_children():
			if child is AnimationPlayer:
				animate_player = child
				break
			if not animate_player:
				push_warning("animate prop true but missing AnimationPlayer in: " + get_parent().name)

func _on_area_entered(area) -> void:
	if area.name == "Player_InteractionArea":
		player_nearby = true
		PropInteract_Item.active_prop = self
		set_process_unhandled_input(true)  

func _on_area_exited(area) -> void:
	if area.name == "Player_InteractionArea":
		player_nearby = false
		if PropInteract_Item.active_prop == self:
			PropInteract_Item.active_prop = null
		set_process_unhandled_input(false) 

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("Interact"):
		return
	if is_interacting:
		return
	if interact_done and not can_interact_multiple_times:
		return
	
	get_viewport().set_input_as_handled()
	is_interacting = true
	await interact()
	is_interacting = false

func interact() -> void:
	SessionState.input_locked = true
	interaction_successful = false
	if !can_interact:
		is_interacting = false 
		return
		
	check_prop_inventory_setting()
	await play_prop_narration()
	
	check_prop_requirements()
	if !interaction_options.is_empty():
		pass
	if play_interact_audio:
		play_prop_audio()
		
	if itemid_to_add != "" and item_to_add != "":
		InventoryManager.add_item(itemid_to_add, item_to_add, itemamount_to_add, interaction_options)
	if stop_adding_item:
		itemid_to_add = ""
		item_to_add = ""
	
	if remove_after:
		queue_free()
		
	if animate_prop and interaction_successful:
		SessionState.input_locked = true
		animate_player.play(animation_name[0], -1, 1)
		await animate_player.animation_finished
		
	
	if interaction_successful:
		interaction_allowed.emit()
	interact_done = true
	is_interacting = false  
	SessionState.input_locked = false

func play_prop_narration() -> void:
	if prop_interact_dialogue.is_empty():
		return

	var resolved_dialogue: Array[String] = []

	for line in prop_interact_dialogue:
		if "{amount}" in line:
			line = line.replace("{amount}", str(itemamount_to_add))
		resolved_dialogue.append(line)

	game.vn_component_manager.get_narration(resolved_dialogue)
	await game.vn_component_manager.narration_finished
	if prop_swap_interact_dialogue:
		prop_interact_dialogue = prop_swap_interact_dialogue
	
func play_prop_audio()->void:
	var prop_audio_player = game.bg_audio_effects as AudioStreamPlayer2D
	prop_audio_player.pitch_scale = 1.25
	prop_audio_player.volume_db = -2.0
	
	if not interaction_successful:
		prop_audio_player.stream = prop_interaction_sounds.get(interact_failed_sound, sound_interact_default)
		prop_audio_player.play()
		return
	
	prop_audio_player.stream = prop_interaction_sounds.get(interact_successful_sound, sound_interact_default)
	prop_audio_player.play()

func check_prop_requirements()->void:
	if required_item_id != "":
		if InventoryManager.has_required_item(required_item_id, required_item_amount):
			InventoryManager.remove_item(required_item_id, required_item_amount)
			if debug:
				SessionState.set_global_data("debug", true)
		else:
			await game.vn_component_manager.get_narration(required_item_dialogue)
			print("You need ", required_item_id, " to interact!")
			is_interacting = false
			SessionState.input_locked = false
			return 
			
	SessionState.set_scene_data(prop_required_data, true)
	interaction_successful = true

func check_prop_inventory_setting()->void:
	if difficulty_based:
		var difficulty = SessionState.get_difficulty()
		match difficulty:
			"easy":
				itemamount_to_add = 1
			"medium":
				itemamount_to_add = 2
			"hard":
				itemamount_to_add = 3
		if item_increment > 0:
			itemamount_to_add += item_increment
