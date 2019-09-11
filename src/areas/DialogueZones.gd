extends Node2D


func _ready():
	
	for i in get_child_count():
		
		get_child(i).connect("body_entered", self, "_on_Body_Entered")
	




func _on_Body_Entered(body):
	
	if body.get_name() == "Player":
		
		
		var dialogue_panel = get_parent().get_parent().ui.dialogue_panel
		dialogue_panel._dialogue_2()
		
		
		
		
		
	
	
	
	
	pass