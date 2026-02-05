extends Node2D
class_name SaveDesk_System
var player_nearby = false

@onready var area_2d: Area2D = $Area2D
var is_interacting = false

func _ready() -> void:
	area_2d.body_entered.connect(player_entered)
	area_2d.body_exited.connect(player_exited)
	pass
	
func _process(_delta: float) -> void:
	if player_nearby and Input.is_action_just_pressed("Interact"):
		if is_interacting:
			return
		#get_tree().paused = true
		is_interacting = true
		player_interact()
		is_interacting = false
		#get_tree().paused = false
		pass
	pass
	
func player_entered(body)->void:
	if body.name == "Player":
		player_nearby = true
	pass
	
func player_exited(body)->void:
	if body.name == "Player":
		player_nearby = false
	pass
	
func player_interact()->void:
	get_tree().paused = true
	var save_ui = get_tree().get_first_node_in_group("ingame_menu")
	save_ui.savedata_save_system_ui()
	pass

func save_data()->void:
	
	pass
