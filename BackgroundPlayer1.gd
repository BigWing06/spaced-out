extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.texture = load('res://tiles/Planet' + str(int(global.currentPlanet)+1) + 'Background.png')
	self.position.y+=600
func _process(delta):
	self.position.x = get_node(global.worldPath+'/Player').position.x
