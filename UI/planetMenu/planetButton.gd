extends Button
onready var globals = get_node("/root/global")
var planetNum

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func showPlanet(num):
	planetNum = num
	text = globals.planetInfo[planetNum]['name']

func _on_Button_pressed():
	get_node('/root/worldMain/planetMenu/infoDisplay').displayPlanet(planetNum)
