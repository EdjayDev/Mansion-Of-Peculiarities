class_name Inventory_Manager
extends Node

signal inventory_updated

var items := {}
var equipped_item = ""

func _ready() -> void:
	inventory_updated.connect(_update_session_inventory)

func add_item(item_id: String, display_name : String, amount: int = 1, actions : Array = []) -> void:
	if items.has(item_id):
		items[item_id]["amount"] += amount
	else:
		items[item_id] = { "display_name" : display_name, "amount" : amount, "actions" : actions}
	inventory_updated.emit()

func add_items(item_array: Array, amount: int = 1, actions : Array = []) -> void:
	print("Items being Added: ", item_array)
	for item in item_array:
		if item.has("choice_itemid") and item.has("choice_item"):
			var id = item["choice_itemid"]
			var display_name = item["choice_item"]
			
			if id == "item_unknownKey":
				display_name = "??? Key"
			if id == "item_ignore":
				return
			add_item(id, display_name, amount, actions)
	inventory_updated.emit()

func remove_item(item_id: String, amount: int = 1) -> void:
	if items.has(item_id):
		items[item_id]["amount"] -= amount
		if items[item_id]["amount"] <= 0:
			items.erase(item_id)
	inventory_updated.emit()

func has_item(item_id: String) -> bool:
	return items.has(item_id)

func has_required_item(item_id : String, amount : int)->bool:
	print ("Required Items Check: ", items.get(item_id, {}).get("amount", 0))
	return items.get(item_id, {}).get("amount", 0) >= amount

func get_item_action(item_id : String)->Array:
	return items.get(item_id, {}).get("actions", [])
	
func get_all_items() -> Dictionary:
	return items

func set_all_items(new_items: Dictionary) -> void:
	items = new_items
	inventory_updated.emit()

func equip_item(item_id : String)->void:
	equipped_item = item_id
	print("Equipped Item: ", equipped_item)
	pass
# ------------------------
# Automatically push to session whenever inventory updates
# ------------------------
func _update_session_inventory() -> void:
	SessionState.player["inventory"] = get_all_items()
