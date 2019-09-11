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
		
		# Move player to target position
		var offset = Vector2(140, 20)
		if flipped:
			offset *= -1
		var new_pos = goto_location + offset
		body.position = new_pos
		
		# Create a checkpoint for the 
		var portal_checkpoint = Node2D.new()
		portal_checkpoint.position = new_pos
		body.set_checkpoint(portal_checkpoint)
