extends Panel

var file : String = "res://src/dialogues/DialoguesStrings.json"

onready var text_label = $RichTextLabel

var scene = ""
var scene_dialogues = {}
var current_line = 0

func _ready():
	visible = false

func _process(delta):
	
	if Input.is_action_just_pressed("enter"):
		continue_dialogue()

func show_dialogue(scene_name):
	
	scene = scene_name
	
	# Get all dialogue from file
	var data_file = File.new()
	data_file.open(file, data_file.READ)
	var data_text = parse_json(data_file.get_as_text())
	data_file.close()
	
	scene_dialogues = data_text[scene_name]
	
	current_line = 1
	text_label.text = scene_dialogues[str(current_line)]
	visible = true

func continue_dialogue():
	
	current_line += 1
	
	# Make sure there is a next line to show
	if current_line <= len(scene_dialogues):
		text_label.text = scene_dialogues[str(current_line)]
	else:
		visible = false
		trigger_event()

func trigger_event():
	match scene:
		"dialogue2":
			# Hardcoding node paths is bad, mmmkay? Mmmkay.
			get_node("/root/Game/Room/Barricades/StatueBarricade01").open_door()
		"dialogue3-over":
			get_node("/root/Game/Room/Portals/Portal03").visible = true
			get_node("/root/Game/Room/Portals/Portal03/CollisionShape2D").set_disabled(false)
		_:
			pass
