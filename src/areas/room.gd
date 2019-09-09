extends Node
class_name BaseRoom

onready var projectiles = $Projectiles
onready var audio_zones = $AudioZones

export(String, FILE, "*.ogg") var default_track : String = "res://assets/audio/music/The_Tale_of_The_Ferry_of_The_Death_arrangement.ogg"

func _ready():
	for zone in audio_zones.get_children():
		zone.connect("body_exited", self, "_on_body_exited")
	AudioEngine.play_background_music(default_track)
#	AudioEngine.play_sound("res://assets/audio/music/Pre_Boss_mixed.wav", true)
	
	
	#randomize()
	pass


func _on_body_exited(body):
	AudioEngine.play_background_music(default_track)
	pass