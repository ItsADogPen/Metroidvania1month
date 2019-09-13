extends StaticBody2D

onready var sprite = $AnimatedSprite
onready var shape = $CollisionShape2D

func open_door():
	sprite.play("open")
	shape.visible = false

func close_door():
	sprite.play("close")
	shape.visible = true
