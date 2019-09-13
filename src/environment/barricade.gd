extends StaticBody2D

export (bool) var start_open = false
export (bool) var trigger_close = false

onready var sprite = $AnimatedSprite
onready var shape = $CollisionShape2D

func _ready():
	if start_open:
		open_door()
	
	# Only activate trigger zone on the boss barricade
	if trigger_close:
		$Area2D.connect("body_entered", self, "_on_body_entered")

func open_door():
	sprite.play("open")
	shape.set_disabled(true)

func close_door():
	sprite.play("close")
	shape.set_disabled(false)

func _on_body_entered(body):
	if body is Player:
		close_door()
