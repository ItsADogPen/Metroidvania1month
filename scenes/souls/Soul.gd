extends Node2D
class_name Soul

signal upgrade_gained

var upgrade = "double_jump"

onready var area = $Area2D
onready var sprite = $AnimatedSprite

func _ready():
	pass

# Function triggered when another body enters this area
func _on_body_entered(body):
	if body is Player:
		emit_signal("upgrade_gained", upgrade)