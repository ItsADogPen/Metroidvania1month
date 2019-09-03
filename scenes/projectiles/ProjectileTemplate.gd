extends Node2D

var time

onready var animation = $AnimatedSprite
onready var anim_player = $AnimationPlayer
onready var area2D = $Area2D
onready var area2D_shape = $Area2D/CollisionShape2D

func _play_Anim(anim_string : String):
	
	animation.play(anim_string)
	
	pass

func _destroy():
	
	self.queue_free()