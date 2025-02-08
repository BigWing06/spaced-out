extends Button


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$QueueTimer.start()


func _on_QueueTimer_timeout():
	queue_free()
