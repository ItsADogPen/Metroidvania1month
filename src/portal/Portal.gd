extends Node2D

export (bool) var flipped = false

onready var sprite = $AnimatedSprite

func _ready():
	sprite.flip_h = flipped
	connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body):
	
	# TODO: Set up teleporting function
	pass