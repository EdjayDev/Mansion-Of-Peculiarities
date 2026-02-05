extends Node
class_name Save_System

const SAVE_PATH := "user://savegame.save"
var is_loading_from_file: bool = false

var save_data: Dictionary = {
	"slot_1": { "slot_status" : "", "player": {}, "world": {}, "global_data": {}, "meta": {} },
	"slot_2": { "slot_status" : "", "player": {}, "world": {}, "global_data": {}, "meta": {} },
	"slot_3": { "slot_status" : "", "player": {}, "world": {}, "global_data": {}, "meta": {} }
}

func _ready() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			save_data = file.get_var()
			file.close()
	#print("Save Data: ", save_data)
	pass
# ------------------------
# Save / Load
# ------------------------
func save_game(slot: int) -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		FileAccess.get_open_error()
		push_error("[SaveSystem] Could not open save file for writing.")
		return
	file.store_var(save_data)
	print("file: ", file)
	file.close()
	print("[SaveSystem] Saved slot %d to %s" % [slot, SAVE_PATH])
	#print("Saved Data\n", save_data)

func save_from_session(slot: int) -> void:
	var slot_key = "slot_%d" % slot

	# Load existing save file
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			save_data = file.get_var()
			file.close()
	else:
		save_data = {
			"slot_1": { "player": {}, "world": {}, "global_data": {}, "meta": {} },
			"slot_2": { "player": {}, "world": {}, "global_data": {}, "meta": {} },
			"slot_3": { "player": {}, "world": {}, "global_data": {}, "meta": {} }
		}

	# 🔥 IMPORTANT: remove INVALID ROOT KEYS
	for bad_key in ["world", "meta", "player"]:
		if save_data.has(bad_key):
			save_data.erase(bad_key)

	# Write slot
	save_data[slot_key]["slot_status"] = SessionState.slot_status.duplicate(true)
	save_data[slot_key]["player"] = SessionState.player.duplicate(true)
	save_data[slot_key]["world"] = SessionState.world.duplicate(true)
	save_data[slot_key]["global_data"] = SessionState.global_data.duplicate(true)
	save_data[slot_key]["meta"] = { "saved_at": Time.get_datetime_dict_from_system() }

	save_game(slot)
	print("[SaveSystem] Slot %d saved successfully." % slot)

func load_game(slot: int) -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("[SaveSystem] No save file found.")
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		push_error("[SaveSystem] Could not open save file for reading.")
		return

	save_data = file.get_var()
	file.close()
	print("[SaveSystem] Save file loaded from disk.")

	var slot_key = "slot_%d" % slot
	if save_data.has(slot_key):
		var slot_data = save_data[slot_key]
		if typeof(slot_data) == TYPE_DICTIONARY:
			is_loading_from_file = true
			SessionState.slot_status = slot_data.get("slot_status", {}).duplicate(true)
			SessionState.player = slot_data.get("player", {}).duplicate(true)
			SessionState.world = slot_data.get("world", {}).duplicate(true)
			SessionState.global_data = slot_data.get("global_data", {}).duplicate(true)
			print("[SaveSystem] SessionState populated from slot %d." % slot)
		else:
			print("[SaveSystem] Slot data invalid.")
	else:
		print("[SaveSystem] Slot %d not found in save file." % slot)

func slot_exists(slot: int) -> bool:
	var slot_key = "slot_%d" % slot
	return save_data.has(slot_key) and save_data[slot_key]["player"].keys().size() > 0

func get_player_data(slot: int) -> Dictionary:
	var slot_key = "slot_%d" % slot
	if save_data.has(slot_key):
		return save_data[slot_key].get("player", {})
	return {}

func get_world_data(slot: int) -> Dictionary:
	var slot_key = "slot_%d" % slot
	if save_data.has(slot_key):
		return save_data[slot_key].get("world", {})
	return {}

func read_slot(slot: int) -> Dictionary:
	var slot_key = "slot_%d" % slot
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		push_error("[SaveSystem] Could not open save file for reading slot %d." % slot)
		return {}
	var all_data = file.get_var()
	file.close()
	if all_data.has(slot_key):
		return all_data[slot_key]
	return {}
