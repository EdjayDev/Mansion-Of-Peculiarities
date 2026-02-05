class_name Player_State_Machine extends Node

var states
var current_state : Player_State
var previous_state : Player_State

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	pass 
	
func _process(delta: float) -> void:
	change_state(current_state.Process(delta))
	pass

func _physics_process(delta: float) -> void:
	change_state(current_state.Physics(delta))
	pass
	
func _input(event) -> void:
	change_state(current_state.HandleInput(event))
	pass
	
func initialize( player : Player ) -> void:
	states = []
	for child in get_children():
		if child is Player_State:
			child.player = player
			states.append(child)
	
	if states.size() > 0:
		current_state = states[0]
		change_state(current_state)
		process_mode = Node.PROCESS_MODE_INHERIT
	pass

func change_state( new_state : Player_State) -> void:
	if new_state == null || new_state == current_state:
		return 
	if current_state:
		current_state.Exit()

	previous_state = current_state	
	current_state = new_state
	current_state.Enter()
	
