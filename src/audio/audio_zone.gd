extends Area2D

export(String, "background", "sound", "effect") var type = "background"
export(String, FILE, "*.ogg") var audio_track

func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")


func _on_body_entered(body):
	if body is Player:
		pass


func _on_body_exited(body):
	if body is Player:
		pass
