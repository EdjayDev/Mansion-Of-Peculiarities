extends CharacterBody2D
class_name BaseNPC

# -----------------------------
# ENUMS & STATE
# -----------------------------
enum NPCState { IDLE, WALK, WANDER }

var state: NPCState = NPCState.IDLE
var prev_state: NPCState = NPCState.IDLE

var is_interacting
# -----------------------------
# NODES & REFERENCES
# -----------------------------
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var npc_dialogue_sprite: Sprite2D = $"Sprite2D-DialogueSprite"

var area_2d: Area2D
var follow_target: Node2D = null
var player_get : Player
var navigation_agent : NavigationAgent2D

var scene_game : Game
# -----------------------------
# EXPORTED / FLAGS
# -----------------------------
@export var npc_name: String
@export var is_following_player: bool = false
var npc_file_path
var is_npc_sync : bool 
var forced_animation := false

# -----------------------------
# DATA
# -----------------------------
var delta_data
var last_direction: String = "down"
var in_cutscene = false
var player_nearby: bool = false
var has_faced_target : bool = false
var cancel_cutscene_movement := false

var follow_speed : float = 100.0
var acceleration = 400
var friction = 400

var npc_dialogue
var npc_choices
var npc_id: String = ""
var choice_id: String

# -----------------------------
# READY
# -----------------------------
func _ready():
	print("NPC Ready:", npc_name)
# -----------------------------
# AREA SIGNALS
# -----------------------------
func _on_area_entered(area: Area2D) -> void:
	var player := area.owner
	if player is Player:
		player_nearby = true
		
func _on_area_exited(area):
	if area.name == "Player_InteractionArea":
		player_nearby = false

func character_in_cutscene_handler() -> void:
	scene_game = get_tree().get_root().get_node("Game")
	if scene_game:
		scene_game.cutscene_started.connect(_on_cutscene_started)
		scene_game.cutscene_finished.connect(_on_cutscene_ended)

		if scene_game.is_in_cutscene:
			_on_cutscene_started()
		
func sync_state()->void:
	print("Syncing State: ", npc_name)
	if SessionState.player_has_companion():
		var player_companion = SessionState.get_companion_id()
		if player_companion.has(npc_id):
			add_to_group("companion")
			print("Character groups:", get_groups())
			follow_target = get_tree().get_first_node_in_group("Player")
			is_following_player = true
	player_get = get_tree().get_first_node_in_group("Player")
	pass
	
func _on_cutscene_started():
	sync_state()
	in_cutscene = true

func _on_cutscene_ended():
	sync_state()
	in_cutscene = false
	
# -----------------------------
# PROCESS (INPUT ONLY)
# -----------------------------
func _process(_delta):
	if in_cutscene:
		is_npc_sync = false
		is_following_player = false
		return

	if player_nearby and Input.is_action_just_pressed("Interact"):
		if is_interacting:
			return
		is_interacting = true
		await interact()
		is_interacting = false
		print("[NPC] NPC ID: ", npc_id)
	
# -----------------------------
# PHYSICS PROCESS
# -----------------------------
func _physics_process(delta):
	delta_data = delta
	if not in_cutscene:
		update_ai_velocity()
	
	#STATE IS DERIVED HERE — ALWAYS
	update_state_from_velocity()
	update_animation()
	move_and_slide()

# -----------------------------
# AI MOVEMENT (ONLY WRITES VELOCITY)
# -----------------------------
func update_ai_velocity():
	if is_following_player and follow_target:
		face_target(follow_target)
		navigation_agent.target_desired_distance = 20.0
		navigation_agent.path_desired_distance = 30.0
		navigation_agent.path_max_distance = 4.0
		follow_speed = follow_target.move_speed

		navigation_agent.target_position = follow_target.global_position
		
		if not navigation_agent.is_navigation_finished():
			var next_pos = navigation_agent.get_next_path_position()
			var dir = (next_pos - global_position).normalized()
			var desired_velocity = dir * follow_speed
			# Smoothly interpolate using acceleration if you want
			navigation_agent.set_velocity(navigation_agent.get_velocity().move_toward(desired_velocity, acceleration * delta_data))
		else:
			navigation_agent.set_velocity(navigation_agent.get_velocity().move_toward(Vector2.ZERO, friction * delta_data))

func on_cutscene_movement(target: Vector2, speed: float) -> void:
	forced_animation = false
	cancel_cutscene_movement = false
	navigation_agent.path_desired_distance = 2.0
	navigation_agent.target_desired_distance = 2.0
	navigation_agent.path_max_distance = 2.0
	navigation_agent.target_position = target
	
	while not navigation_agent.is_navigation_finished():
		if cancel_cutscene_movement:
			velocity = Vector2.ZERO
			return
		var next_position := navigation_agent.get_next_path_position()
		var dir := (next_position - global_position).normalized()

		velocity = dir * speed
		await get_tree().physics_frame
	var direction = (target - global_position).normalized()
	velocity = direction * speed
	if global_position.distance_to(target) <= 2.0:
		velocity = Vector2.ZERO

# -----------------------------
# STATE FROM VELOCITY (IMPORTANT)
# -----------------------------
func update_state_from_velocity():
	if velocity.length() > 0.1:
		state = NPCState.WALK
		pass
	else:
		state = NPCState.IDLE
		pass

# -----------------------------
# ANIMATION (VELOCITY-DRIVEN)
# -----------------------------
func update_animation(custom_animation : String = ""):
	if forced_animation:
		return
	if not custom_animation.is_empty():
		animation_player.play(custom_animation)
		return
	if velocity.length() > 0.1:
		last_direction = animation_direction(velocity)
		animation_player.play("walk_" + last_direction)
	else:
		if animation_player.has_animation("idle_" + last_direction):
			animation_player.play("idle_" + last_direction)

# -----------------------------
# CUTSCENE ANIMATION (OPTIONAL)
# -----------------------------
func play_custom_animation(animation: String, speed : float = 1.0) -> void:
	velocity = Vector2.ZERO
	forced_animation = true
	
	var parts := animation.split("_")
	if parts.size() > 1:
		last_direction = parts[1]
	
	if animation_player.has_animation(animation):
		animation_player.play(animation, -1, speed)
		await animation_player.animation_finished
	else:
		print("Animation not found:", animation)

# -----------------------------
# DIRECTION DECODER
# -----------------------------
func animation_direction(dir: Vector2) -> String:
	if abs(dir.x) > abs(dir.y):
		return "right" if dir.x > 0 else "left"
	else:
		return "down" if dir.y > 0 else "up"

func face_target(face_character: CharacterBody2D) -> void:
	if face_character == null:
		return
	forced_animation = true
	var dir := (face_character.global_position - global_position).normalized()
	var state_name = NPCState.keys()[state].to_lower()
	#print("Direction: ", dir)
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			animation_player.play(state_name + "_right")
		else:
			animation_player.play(state_name + "_left")
	else:
		if dir.y > 0:
			animation_player.play(state_name + "_down")
		else:
			animation_player.play(state_name + "_up")
	
# -----------------------------
# INTERACTION
# -----------------------------
func interact():
	pass

# -----------------------------
# SETTERS
# -----------------------------
func initialize_npc()->void:
	pass

func set_npc_id(id_: String):
	npc_id = id_
	
func set_npc_name(name_: String):
	npc_name = name_

func set_npcdialogue(dialogue_: Array):
	npc_dialogue = dialogue_

func set_npcchoices(choices_: Array):
	npc_choices = choices_

func set_npc_dialogue_sprite(sprite: Sprite2D):
	npc_dialogue_sprite = sprite

func set_area2d(area2d_: Area2D):
	area_2d = area2d_
	area_2d.area_entered.connect(_on_area_entered)
	area_2d.area_exited.connect(_on_area_exited)

func set_navigation_agent(navigation_agent_reference : NavigationAgent2D)->void:
	navigation_agent = navigation_agent_reference
	navigation_agent.radius = 3.0
	navigation_agent.velocity_computed.connect(_on_velocity_computed)
	navigation_agent.avoidance_enabled = true
	navigation_agent.debug_enabled = false
	pass
	
func set_npc_file_path(file_path : String)->void:
	npc_file_path = file_path

func _on_velocity_computed(safe_velocity : Vector2)->void:
	if is_following_player and follow_target:
		var dir = safe_velocity.normalized()
		velocity = dir * follow_target.move_speed * 0.75
	else:
		velocity = safe_velocity
