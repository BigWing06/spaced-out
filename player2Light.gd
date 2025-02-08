extends Light2D
func _process(delta):
	position.x = global.world.get_node("Player2").position.x
