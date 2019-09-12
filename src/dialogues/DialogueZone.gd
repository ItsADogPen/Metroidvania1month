extends Area2D
class_name DialogueZone

export (String, "dialogue2") var scene_name = "dialogue2"

var shown = false

func _ready():
	connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body):
	if body is Player and not shown:
		var panel = get_node("/root/Game/UI/Dialogue/DialoguePanel")
		panel.show_dialogue(scene_name)
		shown = true
