class_name Level_2f_Playground
extends BaseLevel

@onready var prop_book_guide: PropInteract_Item = $Y_Sort/Props/prop_book_guide
@onready var prop_doorsilver: Node2D = $"Y_Sort/Props/prop_doorsilver-type1_"
var open_silverdoor = false

func _ready() -> void:
	set_level_name("2nd Floor Small Room")
	scene_path = "res://game_scenes/level_2f_playground.tscn"

	await init_level()
	print("Level_2f_Playground ready")
	game.set_bgmusic_setting(-10.0, 0.9)
	
	initialize_key()
	# Check if level visited before, and if player got the door keys depending on difficulty
	var visited : bool = SessionState.get_scene_data("visited_before", false)
	
	var has_keys_smallroom : bool = SessionState.get_scene_data("get_roomkeys_smallroom", false)
	prop_book_guide.has_interacted.connect(disable_bookguide)
		
	if not visited:
		SessionState.set_scene_data("visited_before", true)
		show_room_intro_emote()
		 
	if has_keys_smallroom:
		disable_bookguide(true)
		SessionState.set_scene_data("get_roomkeys_smallroom", true)

func _process(_delta: float) -> void:
	if SessionState.get_global_data("playground_silverdoor_unlocked", false):
		if open_silverdoor:
			return
		open_silverdoor = true
		prop_doorsilver.queue_free()
		
func initialize_key()->void:
	var difficulty : String = SessionState.get_difficulty()
	var key_dialogue : Array
	var amount : int
	match difficulty:
		"easy":
			key_dialogue = [
				"OPEN SAYS ME – the silver door opens for 1 key",
				"You received a key!"
			]
			amount = 1
		"medium":
			key_dialogue = [
				"OPEN SAYS ME – the silver door opens for 2 key",
				"You received 2 keys!"
			]
			amount = 2
		"hard":
			key_dialogue = [
				"OPEN SAYS ME – the silver door opens for 3 key",
				"You received 3 keys!"
			]
			amount = 3
	prop_book_guide.prop_interact_dialogue = key_dialogue
	prop_book_guide.itemamount_to_add = amount
	pass

func disable_bookguide(has_interacted : bool)->void:
	if has_interacted:
		SessionState.set_scene_data("get_roomkeys_smallroom", true)
		prop_book_guide.can_interact = false
	pass

func show_room_intro_emote() -> void:
	if player:
		player.show_emote("exclamation")
