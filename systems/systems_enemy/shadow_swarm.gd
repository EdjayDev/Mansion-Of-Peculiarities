extends Node2D
class_name Shadow_Swarm

@export var shadow_area : Area2D
@export var shadow_direction : String = "right"
@export var shadow_scale : Vector2
@export var shadow_spread_speed : float = 0.75
@export var shadow_particle_density_duration : float = 6.0 

@onready var dark_animplayer: AnimationPlayer = $Dark_AnimationPlayer
@onready var shadow_area_2d: Area2D = $ShadowArea2D
@onready var dark_swarm_particle: GPUParticles2D = $Dark_Swarm/dark_swarm_particle

func _ready() -> void:
	shadow_area_2d.body_entered.connect(death)
	dark_swarm_particle.lifetime = shadow_particle_density_duration
	#dark_swarm()

func dark_swarm(duration : float = 0)->void:
	dark_animplayer.play("dark_spread_" + shadow_direction, -1, shadow_spread_speed)
	if duration > 0:
		await get_tree().create_timer(duration).timeout
		dark_animplayer.pause()
	
func death(target_body: CharacterBody2D)->void:
	if target_body.is_in_group("Player"):
		var game = get_tree().get_root().get_node("Game") as Game
		game.set_game_over("CONSUMED", "The shadows engulfed you.", "default")
		await get_tree().create_timer(2.0).timeout
		#dark_animplayer.stop()
	pass

func set_particle_emission(value : bool)->void:
	dark_swarm_particle.emitting = value
