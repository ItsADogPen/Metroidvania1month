extends Node2D

onready var sprite = $AnimatedSprite
onready var animation_player = $AnimationPlayer
onready var area2D = $Area2D


func ready():
	animation_player.connect("animation_finished", self, "_on_animation_finished")

func play_animation(animation : String):
	if animation == "beginning":
		animation_player.play("ExpandCollision")
	elif animation == "end":
		animation_player.play("RetractCollision")
	sprite.play(animation)

func _on_animation_finished(anim_name):
	animation_player.stop(true)
