extends Node2D
class_name Soul

signal upgrade_gained

export (String, "double_jump", "jump_speed", "move_speed", "attack_speed", "attack_aoe", "shield_aoe", "dash") var upgrade

onready var area = $Area2D
onready var sprite = $AnimatedSprite

# Function triggered when another body enters this area
func _on_body_entered(body):
	if body is Player:
		emit_signal("upgrade_gained", upgrade)
