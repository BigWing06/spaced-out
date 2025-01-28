extends CanvasLayer
onready var globals = get_node("/root/global")

func _on_Button_pressed():
	toggleEscape()

func _on_Button2_pressed():
	globals.save()
	get_tree().change_scene("res://UI/startScreen/StartScreen.tscn")
	get_tree().get_current_scene().get_node('Player').get_parent().queue_free()
	globals.gamePaused = true

func toggleEscape():
	if visible == false:
		get_parent().setPauseState(true)
		visible = true
	else:
		get_parent().setPauseState(false)
		visible = false
