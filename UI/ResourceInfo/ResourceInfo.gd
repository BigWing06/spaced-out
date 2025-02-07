extends Node2D

func _ready():
	global.resourceInfoNode=self
func _process(delta):
	if global.hideHud:
		self.hide()
	else:
		self.show()
var lastCell = null
func setText(text):
	$Label.text=text
