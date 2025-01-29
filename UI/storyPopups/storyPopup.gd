extends Control

func _ready():
	setup("bob", "j;lkj;lkj;ljjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjklkj;lkjkj")

func setup(character, text, time=5):
	$AnimationPlayer/name.text = character
	$AnimationPlayer/text.text = text
	$displayTimer.wait_time = time
	#$AnimationPlayer.playback_speed = len($AnimationPlayer/text.text)/5
	$AnimationPlayer.play("showText")
	$displayTimer.start()
func _on_displayTimer_timeout():
	queue_free()
