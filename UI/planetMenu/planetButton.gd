extends TextureButton
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
	$Label.text = globals.planetInfo[planetNum]['name']
	

func _on_Button_pressed():
	get_node('/root/worldMain/planetMenu/infoDisplay').displayPlanet(planetNum)


func _on_Button_mouse_entered():
	$Label.add_color_override("font_color", '#000000')


func _on_Button_mouse_exited():
	$Label.add_color_override("font_color", '#FFFFFF')
