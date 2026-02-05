extends Node2D
class_name PropInteract_Item_UI

@onready var control: Control = $Control
@onready var button: Button = $Control/Button

func show_interaction_options(options : Array)->void:
	for option in options:
		var option_button = button.duplicate()
		option_button.text = option
		control.add_child(option_button)
	pass
