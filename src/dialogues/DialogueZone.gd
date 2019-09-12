extends Area2D
class_name DialogueZone

export (String, "dialogue1", "dialogue2", "dialogue3", "dialogue3-mid", "dialogue3-over", "dialogue4", "dialogue5") var scene_name = "dialogue2"

var shown = false

func _ready():
	connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body):
	if body is Player and not shown:
		var panel = get_node("/root/Game/UI/Dialogue/DialoguePanel")
		panel.show_dialogue(scene_name)
		shown = true
