extends Node2D
onready var viewport1 = $Viewports/ViewportContainer/ViewportPlayer1
onready var viewport2 = $Viewports/ViewportContainer2/ViewportPlayer2
onready var camera1 = $Viewports/ViewportContainer/ViewportPlayer1/Camera2D
onready var camera2 = $Viewports/ViewportContainer2/ViewportPlayer2/Camera2D
onready var world = $Viewports/ViewportContainer/ViewportPlayer1/world
func _ready():
	viewport2.world_2d = viewport1.world_2d
	camera1.target = get_node(global.worldPath+"/Player")
	camera2.target= get_node(global.worldPath+"/Player2")
