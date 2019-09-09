extends Node
class_name BaseRoom

onready var projectiles = $Projectiles

func _ready():
	
	AudioEngine.play_background_music("res://assets/audio/music/newPreBoss/Pre_Boss_mixed.ogg")
#	AudioEngine.play_sound("res://assets/audio/music/Pre_Boss_mixed.wav", true)
	
	
	#randomize()
	pass