extends "res://scenes/projectiles/ProjectileTemplate.gd"

func _play_Anim(anim_string : String):
	
	if anim_string == "beginning":
		anim_player.play("ColliShape")
	elif anim_string == "end":
		anim_player.play("ColliShapeBackwards")
	animation.play(anim_string)

func _on_AnimationPlayer_animation_finished(anim_name):
	
	anim_player.stop(true)
