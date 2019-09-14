extends Area2D

export var damage_frame = 1

onready var animated_sprite = $AnimatedSprite


func _ready():
	animated_sprite.connect("frame_changed", self, "_on_frame_changed")
	
func play():
	animated_sprite.play("default")
	yield(animated_sprite, "animation_finished")
	queue_free()

func _on_frame_changed():
	if animated_sprite.frame == damage_frame:
		for body in get_overlapping_bodies():
			if body is Player:
				body.take_enemy_damage(1)


