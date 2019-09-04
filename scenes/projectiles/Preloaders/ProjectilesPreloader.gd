extends ResourcePreloader

var dictionary = {
	"ProjectileShield" : preload("res://scenes/projectiles/Shield/ProjectileShield.tscn")
}

func _return_Resource(projectileName:String):
	
	var get_resource = dictionary[projectileName]
	return(get_resource)