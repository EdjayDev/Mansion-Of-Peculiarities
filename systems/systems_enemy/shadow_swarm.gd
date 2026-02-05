extends Node2D
class_name Shadow_Swarm

@export var shadow_area : Area2D
@export var shadow_direction : String = "right"
@export var shadow_scale : Vector2
@export var shadow_spread_speed : float = 0.75

@onready var dark_animplayer: AnimationPlayer = $Dark_AnimationPlayer
@onready var shadow_area_2d: Area2D = $ShadowArea2D

func _ready() -> void:
	shadow_area_2d.body_entered.connect(death)
	pass

func dark_swarm()->void:
	dark_animplayer.play("dark_spread_" + shadow_direction, shadow_spread_speed)
	
func death(target_body: CharacterBody2D)->void:
	if target_body.is_in_group("Player"):
		var game = get_tree().get_root().get_node("Game") as Game
		game.set_game_over("CONSUMED", "The shadows engulfed you.")
	pass
