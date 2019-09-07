extends Node2D
class_name Soul

signal upgrade_gained

export (String, "double_jump", "jump_speed", "move_speed", "attack_speed", "attack_aoe", "shield_aoe", "dash") var upgrade
export (SpriteFrames) var frames

onready var sprite = $AnimatedSprite

func _ready():
	
	# Set sprite to correct image
	sprite.frames = frames
	sprite.animation = "idle"
	sprite.playing = true

# Function triggered when another body enters this area
func _on_body_entered(body):
	if body is Player:
		emit_signal("upgrade_gained", upgrade)
		print("Collected soul!")
		
		# Remove this soul from level
		visible = false
		queue_free()
