extends Node
class_name BaseRoom

onready var projectiles = $Projectiles
onready var audio_zones = $AudioZones

export(String, FILE, "*.ogg") var default_track : String = "res://assets/audio/music/The_Tale_of_The_Ferry_of_The_Death_arrangement.ogg"

func _ready():
	for zone in audio_zones.get_children():
		zone.connect("body_exited", self, "_on_audio_zone_exited")
	AudioEngine.play_background_music(default_track)
#	AudioEngine.play_sound("res://assets/audio/music/Pre_Boss_mixed.wav", true)
	
	# Disable dialogue zones that are triggered by in-game events
	get_node("DialogueZones/DialogueBossTransform/CollisionShape2D").set_disabled(true)
	get_node("DialogueZones/DialogueBossDeath/CollisionShape2D").set_disabled(true)
	get_node("DialogueZones/DialogueZone04/CollisionShape2D").set_disabled(true)
	get_node("DialogueZones/DialogueBossStartRetry/CollisionShape2D").set_disabled(true)
	
	for boss in get_tree().get_nodes_in_group("alraune"):
		boss.connect("projectile", self, "_on_boss_projectile")
		
	$Player.connect("death", self, "_on_player_death")
	
	
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.global_position.y < $Levels/First.global_position.y:
			enemy.level = "Regular"
		else:
			if enemy.name.begins_with("Mushroom"):
				enemy.level = "Transform"
			elif enemy.name.begins_with("Slime"):
				enemy.level = "Monster"
				enemy._transform()
	
	#randomize()
	
func _on_boss_projectile(projectile_type):
	if projectile_type == "normal":
		print("Normal projectile fired")
	else:
		print("Transformed projectile fired!")

func _on_audio_zone_exited(body):
	AudioEngine.play_background_music(default_track)
	pass
	
func _on_player_death():
	$Enemies/DetectionZone/Alraune.reset_after_death()
	$Barricades/OvergrownBarricade01.open_door()
	if get_node("DialogueZones/DialogueBossStart").shown:
		get_node("DialogueZones/DialogueBossStartRetry").reset()