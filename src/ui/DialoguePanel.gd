extends Panel

var file : String = "res://src/dialogues/DialoguesStrings.json"

onready var text_label = $RichTextLabel
onready var player_portrait = $PlayerPortait
onready var target_portrait = $TargetPortrait

onready var portraits = {
	"death": preload("res://assets/Hud/portraits/Death.png"),
	"rosemary-normal": preload("res://assets/Hud/portraits/Alraune form.png"),
	"rosemary-monster": preload("res://assets/Hud/portraits/Monster form.png"),
	"mystery-voice": preload("res://assets/Hud/portraits/Mystery Voice.png"),
	"book-merly": preload("res://assets/Books/MerlyBook1.png"),
	"book-agent": preload("res://assets/Books/AgentBook1.png"),
	"book-antony": preload("res://assets/Books/AntonyBook1.png"),
	"book-death": preload("res://assets/Books/DeathBook1.png"),
	"book-doggie": preload("res://assets/Books/DoggieBook1.png"),
	"book-inher": preload("res://assets/Books/InherBook1.png"),
	"book-jordan": preload("res://assets/Books/JordanBook1.png"),
	"book-willow": preload("res://assets/Books/WillowBook1.png"),
}
	

var scene = ""
var scene_dialogues = {}
var current_line = 0

signal finished

func _ready():
	text_label.set_override_selected_font_color(true)
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
	visible = true
	show_line()
	
	
func show_line():
	if scene_dialogues.has(str(current_line)):
		text_label.text = scene_dialogues[str(current_line)]["text"]
		var color = scene_dialogues[str(current_line)]["color"]
		text_label.add_color_override("default_color", match_color(color))
		if color == "white":
			player_portrait.show()
			target_portrait.hide()
		else:
			player_portrait.hide()
			var target_texture = portraits.get(scene_dialogues.get("target", {}).get(color))
			if target_texture:
				target_portrait.show()
				target_portrait.texture = target_texture
	else:
		visible = false
		trigger_event()
		emit_signal("finished")

func continue_dialogue():
	
	current_line += 1
	
	show_line()


func match_color(col : String) -> Color:
	match col:
		"white":
			return Color(1, 1, 1)
		"grey":
			return Color(0.3, 0.3, 0.3)
		"green":
			return Color(0, 1, 0)
		"red":
			return Color(1, 0, 0)
		_:
			return Color(0, 0, 0)

func trigger_event():
	match scene:
		"dialogue2":
			# Hardcoding node paths is bad, mmmkay? Mmmkay.
			# Definitely mmkay.
			get_node("/root/Game/Room/Barricades/StatueBarricade01").open_door()
		"dialogue-retry":
			# activates boss
			get_node("/root/Game/Room/Enemies/DetectionZone/Alraune").activate()
			get_node("/root/Game/Room/Barricades/OvergrownBarricade01").close_door()
		"dialogue3":
			# activates boss
			get_node("/root/Game/Room/Enemies/DetectionZone/Alraune").activate()
			get_node("/root/Game/Room/Barricades/OvergrownBarricade01").close_door()
		"dialogue3-over":
			get_node("/root/Game/Room/Barricades/OvergrownBarricade01").open_door()
		"dialogue4":
			get_node("/root/Game/Room/Barricades/StatueBarricade02").open_door()
		_:
			pass
