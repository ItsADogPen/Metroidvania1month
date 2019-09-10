extends Node2D
class_name Portal

export (bool) var flipped = false
export (Vector2) var goto_location = Vector2(0,0)

onready var sprite = $AnimatedSprite

func _ready():
	sprite.flip_h = flipped
	connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body):
	if body is Player:
		
		var offset = Vector2(140, 20)
		if flipped:
			offset *= -1
		
		body.position = goto_location + offset
