extends Node2D

onready var frame = $Frame

var damage_counter = 1

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

func _on_health_lost():
	
	frame.play()
	yield(frame, "animation_finished")
	frame.stop()
	damage_counter += 1
	frame.animation = "damage%2d" % damage_counter
