extends Area2D


var owner_group = null

export var velocity = 200
export var gravity_influence = 0

var acceleration = Vector2(0, 0)

func ready():
	connect("body_entered", self, "_on_body_entered")
		
func set_owner(owner):
	owner_group = owner
	
func _on_body_entered(body: Node):
	if not body.is_in_group(owner_group):
		print("hit")

func _physics_process(delta):
	acceleration += Vector2(0, gravity_influence) * delta
	var actual_velocity = Vector2(
	
	position += 1 / 2 * acceleration * delta * delta + velocity + Vector2(velocity, 0) * delta

