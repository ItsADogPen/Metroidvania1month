extends Area2D

onready var area = $Area2D
onready var sprite = $AnimatedSprite

signal reached(checkpoint)

var _reached = true

func _ready():
	connect("body_entered", self, "_on_body_entered")
	
func set_reached():
	sprite.animation = "reached"

func set_unreached():
	sprite.animation = "unreached"

# Kept like this to make the last checkpoint checked the active one later on perhaps?
func _on_body_entered(body: PhysicsBody2D):
	if body.is_in_group("player"):
		emit_signal("reached", self)
