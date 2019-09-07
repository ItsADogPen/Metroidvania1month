extends Node2D
class_name Soul

export (String, "double_jump", "jump_speed", "move_speed", "attack_speed", "attack_aoe", "shield_aoe", "dash") var upgrade = "double_jump"

onready var sprite = $AnimatedSprite

var taken = false


func _ready():
	# Set sprite to correct image
	sprite.animation = "idle"
	sprite.playing = true

# Function triggered when another body enters this area
func _on_body_entered(body):
	if body is Player:
		if not taken:
			taken = true
			body.unlock_upgrade(upgrade)
			
			# Remove this soul from level
			sprite.animation = "disappear"
			yield(sprite, "animation_finished")
			queue_free()
