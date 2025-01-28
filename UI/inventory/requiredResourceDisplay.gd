extends Control
onready var globals = get_node("/root/global")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func display(info):
	$amount.text = str(info[1])
	var resourceName = globals.resourceInfo[info[0]]['name']
	$name.text = str(resourceName)
	$icon.texture = load('res://resourceImages/' + resourceName + '/' + resourceName + 'Inventory.png')

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
