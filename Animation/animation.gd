extends Node2D
var nextScene =  "res://Main.tscn"
var animation = "Intro"

func _ready():
	$AnimationPlayer.play(animation)


func _on_AnimationPlayer_animation_finished(anim_name):
	global.gamePaused = false
	get_tree().change_scene(nextScene)
