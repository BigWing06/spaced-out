extends CanvasLayer
onready var globals = get_node("/root/global")

func _on_Button_pressed():
	toggleEscape()

func _on_Button2_pressed():
	globals.save()
	get_tree().change_scene("res://UI/startScreen/StartScreen.tscn")
	get_node(global.worldPath+'/Player').get_parent().queue_free()
	globals.gamePaused = true

func toggleEscape():
	if visible == false:
		get_parent().setPauseState(true)
		visible = true
		global.main.splitScreenOff()
	else:
		get_parent().setPauseState(false)
		visible = false
		global.main.splitScreenOn()
