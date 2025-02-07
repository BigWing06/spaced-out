extends TextureButton
onready var globals = get_node("/root/global")
var item = null
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func showItem(i):
	item = i
	$itemName.text = globals.resourceInfo[item]['name']
	$icon.texture = load('res://resourceImages/' + globals.resourceInfo[item]['name'] + '/' + globals.resourceInfo[item]['name'] + 'Inventory.png')


func _on_Control_pressed():
	get_node(global.worldPath+'/inventory/craftMenu/upgradeViewer').display(item)
