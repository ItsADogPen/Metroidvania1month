extends KinematicBody2D
class_name Enemy



const UP = Vector2(0, -1)


export(String, "Regular", "Transform", "Monster") var level

export var REGULAR_HEALTH = 10
export var MONSTER_HEALTH = 20

export var ACCELERATION = 200
export var SPEED = 0
export var FRICTION = 0
export var GRAVITY = 10
export var MAX_GRAVITY = 1000


## Vector Variables and ETC ##
var motion: Vector2 = Vector2(0, 0)


var isAir : bool
var isWall = [false, "none"]
var stateMachine : String = "idle"

const SLOPE_SLIDE_STOP = 640

## Nodes variables ##
onready var animation_player = $AnimationPlayer
onready var sprite = $AnimatedSprite

onready var rays = {
	"up": $RayCasts/Up,
	"down": $RayCasts/Down,
	"right": $RayCasts/Right,
	"left": $RayCasts/Left,
	"right_corner": $RayCasts/RightCorner,
	"left_corner": $RayCasts/LeftCorner
}

onready var hit_detection_area = $DetectionArea



export(int) var patrol_distance

# Idea I have to  manage the attacks to not hit twice
var taken_damage_ids = []


var stats = {
	"health": 1,
	"transformed": false
}

var transforming = false

func is_alive():
	return stats.health > 0

func _initialize():  # OVERRIDE THIS IN EACH INDIVIDUAL ENEMY AI
	
	pass

func take_damage(damage: int):
	if is_alive() and not transforming:
		stats.health -= damage
		if not stats.transformed and level == "Transform":
			_transform()
		if not is_alive():
			_die()


func _transform():
	print("Transforming")
	stats.health = MONSTER_HEALTH
	stats.transformed = true
	transforming = true
	sprite.play("transformation")
	yield(sprite, "animation_finished")
	sprite.play("transformed_idle")
	transforming = false


func _die():
	$CollisionShape2D.shape = null
	if stats.transformed:
		sprite.play("transformed_death")
	else:
		sprite.play("normal_death")

	yield(sprite, "animation_finished")
	self.queue_free()
#	sprite.hide()
#	yield(get_tree().create_timer(0.1),"timeout")



func _ready():
	hit_detection_area.connect("body_entered",self,"_on_body_entered")
	
	stats.health = REGULAR_HEALTH
	
	if level == "Monster":
		_transform()

########################################
#ALL AI LOGICS BELOW SHOULD ONLY BE OVERIDDEN AND CODED IN INDIVIDUAL ENEMY AI. THIS IS JUST A TEMPLATE THAT WILL INTERACT WITH VARIOUS FUNCTIONS
#FROM ABOVE
########################################


func horizontal_patrol():
	if not rays.right_corner.is_colliding() || not rays.left_corner.is_colliding():
		var move_direction = int(rays.right_corner.is_colliding()) - int(rays.left_corner.is_colliding())	
		motion.x *= move_direction
	
	if rays.right.is_colliding() || rays.left.is_colliding():
		var move_direction = int(rays.right.is_colliding()) - int(rays.left.is_colliding())
		motion.x *= move_direction


func movement():
	pass


# This doesn't need to be here per so? Maybe use a proximity zone to trigger an attack?
# TODO explore idea
func _on_body_entered(body: Node):
	pass

func attack():
	pass