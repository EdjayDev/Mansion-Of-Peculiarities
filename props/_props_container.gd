extends Node2D
class_name _Props_Container

func _ready():
	for prop in get_children():
		add_to_group("prop")
		_setup_prop(prop)

func _setup_prop(prop: Node2D):
	if prop.name.begins_with("prop_light"):
		return
	if prop.name.begins_with("prop_"):
		var notifier := VisibleOnScreenNotifier2D.new()
		notifier.rect = _calculate_prop_rect(prop)
		prop.add_child(notifier)
		notifier.screen_entered.connect(func(): _on_prop_enter(prop))
		notifier.screen_exited.connect(func(): _on_prop_exit(prop))
	pass

func _on_prop_enter(prop: Node2D):
	for nodes in prop.get_children():
		if prop.name.begins_with("prop_light"):
			return
		if nodes is CanvasItem and nodes is not VisibleOnScreenNotifier2D:
			nodes.visible = true
			nodes.process_mode = Node.PROCESS_MODE_INHERIT 
			

func _on_prop_exit(prop: Node2D):
	for nodes in prop.get_children():
		if prop.name.begins_with("prop_light"):
			return
		if nodes is CanvasItem and nodes is not VisibleOnScreenNotifier2D:
			nodes.visible = false
			nodes.process_mode = Node.PROCESS_MODE_DISABLED


func _calculate_prop_rect(prop: Node2D) -> Rect2:
	var rect := Rect2()
	for child in prop.get_children():
		if child is Sprite2D:
			rect = rect.merge(child.get_rect())
	return rect.grow(20)
