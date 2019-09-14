extends Node2D
class_name BaseRoom

onready var projectiles = $Projectiles
onready var audio_zones = $AudioZones
onready var tilesets = $Tilesets

onready var SpikesInstance = preload("res://src/projectiles/SpikesProjectile.tscn")
onready var BulbInstance = preload("res://src/projectiles/BulbProjectile.tscn")

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
		boss.connect("new_phase", self, "_on_boss_new_phase")
		
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
	
func _on_boss_new_phase():
	for projectile in projectiles.get_children():
		projectile.queue_free()
	
func get_tile_under_player_position():
	var player_position = $Player.global_position
	for tileset in tilesets.get_children():
		var tilemap: TileMap = tileset
		for i in range(6):
			print(tilesets.position)
			var vector = (player_position + Vector2(0, 48 * i) - position) / 3
			var cell = tilemap.get_cellv(tilemap.world_to_map(vector))
			if cell != -1:
#				print("tile ", cell, " exists in tilemap ", tilemap.name, "at vector ", vector, " on index ", i)
				return tilemap.map_to_world(tilemap.world_to_map(vector)) * 3 + position
		tilemap.world_to_map(player_position)
	
func instance_spikes():
	var spikes_instance = SpikesInstance.instance()
	projectiles.add_child(spikes_instance)
	return spikes_instance
	
func instance_bulb():
	var bulb_instance = BulbInstance.instance()
	projectiles.add_child(bulb_instance)
	return bulb_instance
	
func _on_boss_projectile(projectile_type):
	# might work with raycast...
	var projectile_position = get_tile_under_player_position()
	projectile_position.x = $Player.global_position.x
	var projectile
	if projectile_type == "normal":
		projectile = instance_spikes()

		print("Normal projectile fired")
	else:
		projectile = instance_bulb()
		print("Transformed projectile fired!")
	projectile.global_position = projectile_position
	projectile.play()

func _on_audio_zone_exited(body):
	AudioEngine.play_background_music(default_track)
	pass
	
func _on_player_death():
	$Enemies/DetectionZone/Alraune.reset_after_death()
	$Barricades/OvergrownBarricade01.open_door()
	if get_node("DialogueZones/DialogueBossStart").shown:
		get_node("DialogueZones/DialogueBossStartRetry").reset()