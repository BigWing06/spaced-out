extends CanvasLayer
onready var globals = get_node("/root/global")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var planetButton = preload("res://UI/planetMenu/planetButton.tscn")
	for i in range(len(globals.planetInfo)):
		var bttn = planetButton.instance()
		$VBoxContainer.add_child(bttn)
		bttn.showPlanet(i)
func toggleEscape():
	if visible == false and global.currentOverlay == "none":
		global.hideHud = true
		global.main.splitScreenOff()
		globals.currentMenu = self
		get_parent().setPauseState(true)
		visible = true
		$infoDisplay.isValid()
		global.currentOverlay = "planet"
	elif global.currentOverlay == "planet":
		global.hideHud = false
		global.main.splitScreenOn()
		globals.currentMenu = get_node('/root/worldMain/pauseMenu')
		get_parent().setPauseState(false)
		visible = false
		global.currentOverlay = "none"

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
