extends Panel

var file : String = "res://src/dialogues/DialoguesStrings.json"

onready var text_label = $RichTextLabel

var scene_dialogues = {}

func _ready():
	
	_switch(false)
	
	pass

func _process(delta):
	
	var enter = Input.is_action_just_pressed("enter")
	
	if visible == true && enter:
		
		_dialogue_Manager(scene_dialogues.keys(), enter)
	
	
	
	pass


func _switch(argument:bool):
	
	visible = argument
	


func _dialogue_2():
	
	
	var data_file = File.new()
	data_file.open(file, data_file.READ)
	var data_text = parse_json(data_file.get_as_text())
	data_file.close()
	
	
	var dialogues = data_text["dialogue2"]
	
	
	_switch(true)
	
	var string_1 = "dialogue_"
	var num = 1
	for i in dialogues.size():
		
		scene_dialogues[string_1+str(num)] = dialogues[str(num)]
		
		
		num += 1
	
	num = 1
	text_label.text = scene_dialogues[string_1+str(num)]
	scene_dialogues.erase(string_1+str(num))
	
	
	pass

func _dialogue_Manager(keys:Array, enter_key):
	
	
	if enter_key:
		
		if scene_dialogues.size() > 0:
			text_label.text = scene_dialogues[keys[0]]
			scene_dialogues.erase(keys[0])
		else:
			_switch(false)
	
	
	
	pass