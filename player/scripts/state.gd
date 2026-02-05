#Blueprint for player state
class_name Player_State extends Node

#reference to player
static var player : Player

## What happens when the player enter thi state?
func Enter() -> void:
	pass

## What happens when the player exits thi state?
func Exit() -> void:
	pass

## What happens during _process update in this state?
func Process( _delta : float ) -> Player_State:
	return null
	
## What happens during the _physics_process update in this state?
func Physics( _delta : float) -> Player_State:
	return null

## What happens to the inputs during this state?
func handle_input( _event : InputEvent ) -> Player_State:
	return null
