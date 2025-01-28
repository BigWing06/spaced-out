extends CanvasLayer
onready var globals = get_node("/root/global")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var depth = globals.getTileMapPos(get_tree().get_current_scene().get_node('Player').position).y - 8
	if depth < 0:
		depth = 0
	$Label.text = "Depth: " + str(depth)
	$oxygenBar.value = globals.oxygenLevel
	$healthBar.value = globals.playerInfo['health']
