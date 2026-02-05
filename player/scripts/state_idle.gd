#extends parent / blueprint -> state
class_name State_Idle extends Player_State

@onready var walk: State_Walk = $"../Walk"

#reference to player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# What happens when the player enter this state?
func Enter() -> void:
	player.update_animation("idle")
	pass

## What happens when the player exits this state?
func Exit() -> void:
	pass

## What happens during _process update in this state?
func Process( _delta: float) -> Player_State:
	if player.movement_direction != Vector2.ZERO:
		return walk
	player.velocity = Vector2.ZERO
	return null
	
## What happens during the _physics_process update in this state?
func Physics( _delta : float) -> Player_State:
	return null

## What happens to the inputs during this state?
func HandleInput( _event : InputEvent ) -> Player_State:
	#if _event.is_action_pressed(""):
	#	pass
	return null	
