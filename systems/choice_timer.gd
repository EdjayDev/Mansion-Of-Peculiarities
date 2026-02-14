extends CanvasLayer
class_name Choice_Timer

signal choice_timer_finished

@onready var container: CenterContainer = $Control/Container
@onready var choicetimer_player: AnimatedSprite2D = $Control/Container/ChoiceTimer_Player

func _ready() -> void:
	choicetimer_player.visible = false
	
func start_choice_timer()->void:
	choicetimer_player.visible = true
	choicetimer_player.frame = 0
	var half_y = container.size.y / 2
	var half_x = container.size.x / 2
	choicetimer_player.position = Vector2(half_x, half_y)
	choicetimer_player.play("choice_timer_countdown", 1.0)
	await choicetimer_player.animation_finished
	choice_timer_finished.emit()
	
func set_consequence()->void:
	pass
	
