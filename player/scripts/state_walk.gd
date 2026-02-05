class_name State_Walk extends Player_State

#states available
@onready var idle: State_Idle = $"../Idle"
#reference to player
@export var walk_sound : AudioStream
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $"../../Audio/AudioStreamPlayer2D"

var step_timer := 0.0
var step_interval := 0.35   # default step spacing

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

## What happens when the player enter thi state?
## What happens when the player enters this State?
func Enter() -> void:
	player.update_animation("walk")
	step_timer = 0.0
	pass

func Exit() -> void:
	audio_stream_player_2d.stop()
	pass

func Process(_delta : float) -> Player_State:
	if player.movement_direction == Vector2.ZERO:
		return idle
	if Input.is_action_pressed("RunShift"):
		player.move_speed = 150.0
		step_interval = 0.25
	else:
		player.move_speed = 100.0
		step_interval = 0.35
	if player.set_facingdirection():
		player.update_animation("walk")
	#dprint("walk speed ", move_speed)
	player.velocity = player.movement_direction * player.move_speed
	step_timer -= _delta
	if step_timer <= 0:
		play_footstep()
		step_timer = step_interval
		
	return null
	
func Physics( _delta : float ) -> Player_State:
	return null

func HandleInput( _event : InputEvent ) -> Player_State:
	#if event.is_action_pressed(""):
		#pass
	return null	

func play_footstep()->void:
	audio_stream_player_2d.stream = walk_sound
	audio_stream_player_2d.pitch_scale = randf_range(0.75, 1.35)
	audio_stream_player_2d.volume_db = -2
	audio_stream_player_2d.play()
	pass
