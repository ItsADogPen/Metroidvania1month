extends Area2D

onready var area = $Area2D
onready var sprite = $AnimatedSprite

var _reached = false

func _ready():
	connect("body_entered", self, "_on_body_entered")
	
func set_reached():
	_reached = true
	sprite.animation = "reached"

func set_unreached():
	_reached = false
	sprite.animation = "unreached"

# Kept like this to make the last checkpoint checked the active one later on perhaps?
func _on_body_entered(body: PhysicsBody2D):
	if body is Player:
		set_reached()
		body.set_checkpoint(self)
