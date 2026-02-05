extends Node2D
class_name SceneTransitioner

@export var auto_trigger : bool = true
@export var load_level: String
@export var randomize_level : bool = false
@export var random_level_list : Array[String] = []
@export var spawn_marker_name: String = ""  # e.g. "Player_Spawn"
@export var companion_spawn_marker: Array = []
@export var autosave_on_transition: bool = false

@onready var area_2d: Area2D = $Area2D

var is_transitioning := false
var transition_cooldown := 0.0
const COOLDOWN_TIME = 1.0

func _ready() -> void:
	if auto_trigger:
		if area_2d:
			area_2d.body_entered.connect(_on_body_entered)
			area_2d.body_exited.connect(_on_body_exited)
	var prop_interact := get_parent().get_node_or_null("PropInteractItem_Component")
	if prop_interact:
		prop_interact.interaction_allowed.connect(_start_transition)

func _process(delta: float) -> void:
	if transition_cooldown > 0:
		transition_cooldown -= delta

func _on_body_entered(body: Node) -> void:
	if body.name != "Player":
		return
	if is_transitioning or transition_cooldown > 0:
		return
	_start_transition()

func _on_body_exited(body: Node) -> void:
	if body.name == "Player":
		transition_cooldown = 0.0

func start_forced_transition():
	if is_transitioning:
		return
	_start_transition()

# ---------------------------------------------------------------------
func _start_transition() -> void:
	var game = get_tree().get_root().get_node_or_null("Game") as Game
	if is_transitioning:
		return
	if game.is_in_cutscene:
		await game.cutscene_finished
		print("[SCenetransi] cutscene done")
	if randomize_level:
		spawn_marker_name = "Player_fromRandom"
		companion_spawn_marker = ["Companion_fromRandom"]
	print("[SCenetransi] Continuing transition")
	is_transitioning = true
	transition_cooldown = COOLDOWN_TIME

	var player = get_tree().get_first_node_in_group("Player")

	# -------------------- SAVE PLAYER --------------------
	if player:
		SessionState.set_player_health(player.health)
		SessionState.set_inventory(InventoryManager.get_all_items())

		if spawn_marker_name == "":
			SessionState.set_player_position(
				SessionState.world["current_level_name"],
				player.global_position
			)
			print("[SceneTransitioner] Saved player position (no marker).")
		else:
			print("[SceneTransitioner] Using spawn marker:", spawn_marker_name)
			
	#NPCS
	if get_tree().get_node_count_in_group("npc") > 0:
		for npc in get_tree().get_nodes_in_group("npc"):
			SessionState.set_npc_position(npc.npc_id, SessionState.world["current_level_name"], npc.global_position)
		pass
	
	# -------------------- SAVE COMPANION --------------------
	if player and SessionState.player_has_companion():
		print(SessionState.player_has_companion())
		var companion_name = SessionState.get_companion_id()
		SessionState.get_companion_id()
		print("[SceneTransitioner] Saved companion:", companion_name)

	# -------------------- SAVE MARKERS --------------------
	SessionState.world["requested_spawn_marker"] = spawn_marker_name
	SessionState.world["requested_companion_marker"] = companion_spawn_marker
	
	# Save target level
	SessionState.set_current_level(load_level)

	if autosave_on_transition:
		SaveSystem.save_from_session(1)

	print("Entering Other Level: ", SessionState.world["requested_companion_marker"])
	call_deferred("_delegate_scene_change")

func _delegate_scene_change() -> void:
	print("loading level on transition")
	var game = get_tree().get_root().get_node_or_null("Game") as Game
	if not game:
		push_error("[SceneTransitioner] Game node not found!")
		is_transitioning = false
		return
	if not game.has_method("load_level"):
		push_error("[SceneTransitioner] Game.load_level() not found!")
		is_transitioning = false
		return

	if randomize_level and not random_level_list.is_empty():
		load_level = random_level_list.pick_random()
	await game.load_level(load_level, spawn_marker_name, companion_spawn_marker)
	
	is_transitioning = false
