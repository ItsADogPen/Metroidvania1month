extends Node2D

onready var frame = $Frame

var damage_counter = 0

func _on_soul_gained(power):
	match power:
		"shield_aoe":
			$SoulSky.visible = true
		"attack_aoe":
			$SoulBlue.visible = true
		"double_jump":
			$SoulGreen.visible = true
		"attack_speed":
			$SoulPink.visible = true
		"jump_speed":
			$SoulPurple.visible = true
		"move_speed":
			$SoulRed.visible = true
		"dash":
			$SoulYellow.visible = true

func _on_health_lost(num : int):
	
	damage_counter += num
	damage_counter = min(damage_counter, 4)
	frame.animation = "damage%02d" % damage_counter
	frame.play()

func _on_health_reset():
	
	damage_counter = 0
	frame.animation = "damage01"
	frame.stop()
