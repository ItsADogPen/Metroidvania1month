extends KinematicBody2D
class_name Enemy


const UP = Vector2(0, -1)


export(String, "Regular", "Transform", "Monster") var level

enum State {PATROL, CHASE, ATTACK, TAKE_DAMAGE, TRANSFORMING, DYING}

export var REGULAR_HEALTH = 10
export var MONSTER_HEALTH = 20

export var ACCELERATION = 200
export var SPEED = 0
export var FRICTION = 0
export var GRAVITY = 10
export var MAX_GRAVITY = 1000

var state = State.PATROL


signal animation_event


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

onready var hit_detection_area = $AttackDetectionArea


export(int) var patrol_distance

# Idea I have to  manage the attacks to not hit twice
var taken_damage_ids = []


var stats = {
	"health": 1,
	"transformed": false
}

var transforming = false

var chasing = null

func _ready():
	hit_detection_area.connect("body_entered",self,"_on_body_entered_attack_zone")
	
	
	stats.health = REGULAR_HEALTH
	
	if level == "Monster":
		_transform()
		
	randomize()
	set_physics_process(false)
	_initialize()
	set_physics_process(true)

func reboot_horizontal_motion():
	var math = [1,-1]
	var pick_math = math[randi() % math.size()]
	motion.x = (pick_math * (SPEED + ACCELERATION))

func restore_speed():
	if motion.x > 0:
		if motion.x < SPEED + ACCELERATION:
			motion.x  = SPEED + ACCELERATION
	elif motion.x < 0:
		if motion.x > -(SPEED + ACCELERATION):
			motion.x  = -(SPEED + ACCELERATION)

func is_alive():
	return stats.health > 0
	
func set_patrol():
	print("Set patrol")
	chasing = null
	if state == State.CHASE:
		state = State.PATROL
	
func set_chase(player):
	print("Set chase")
	chasing = player
	if state == State.PATROL:
		state = State.CHASE
	

func _on_body_entered_attack_zone(body):
	if state == State.CHASE and body is Player:
		attack()

func _initialize():
	if level == "Monster":
		stats.health = MONSTER_HEALTH
	else:
		stats.health = REGULAR_HEALTH
	
	# random placement
	reboot_horizontal_motion()

func take_damage(damage: int):
	if is_alive() and state != State.TRANSFORMING:
		stats.health -= damage
		if not stats.transformed and level == "Transform":
			_transform()
		if not is_alive():
			_die()


func _transform():
	motion.x = 0
	state = State.TRANSFORMING
	stats.health = MONSTER_HEALTH
	stats.transformed = true
	sprite.play("transformation")
	yield(sprite, "animation_finished")
	if chasing:
		state = State.CHASE
	else:
		state = State.PATROL


func _die():
	$CollisionShape2D.shape = null
	motion.x = 0
	state = State.DYING
	if stats.transformed:
		sprite.play("transformed_death")
	else:
		sprite.play("normal_death")

	yield(sprite, "animation_finished")
	self.queue_free()
#	sprite.hide()
#	yield(get_tree().create_timer(0.1),"timeout")


func horizontal_patrol():
#	print(rays.right_corner.is_colliding(), " ", rays.left_corner.is_colliding())
	if not rays.right_corner.is_colliding() || not rays.left_corner.is_colliding():
		var move_direction = int(rays.right_corner.is_colliding()) - int(rays.left_corner.is_colliding())
		motion.x = (SPEED + ACCELERATION) * move_direction
	
#	print(rays.right.is_colliding(), " ", rays.left.is_colliding())
	if rays.right.is_colliding() || rays.left.is_colliding():
#		print(rays.right.get_collider(), rays.left.get_collider(), self)
		var move_direction = int(rays.right.is_colliding()) - int(rays.left.is_colliding())
		motion.x = -(SPEED + ACCELERATION) * move_direction
		
func get_chasing_direction():
	if chasing:
		var distance = chasing.global_position.x - global_position.x
		return sign(distance)
	
func chase():
	if motion.x == 0:
		reboot_horizontal_motion()
		
	restore_speed()
	
	motion.x = get_chasing_direction() * (SPEED + ACCELERATION)
	
func attack():
	motion.x = 0
	
	state = State.ATTACK
	
	if stats.transformed:
		sprite.play("transformed_attack")
	else:
		sprite.play("normal_attack")
	yield(sprite, "animation_finished")
	
	if chasing:
		state = State.CHASE
	else:
		state = State.PATROL
	
	
func set_animation():
	if state == State.PATROL or state == State.CHASE:
		if stats.transformed:
			if sprite.animation != "transformed_walk":
				sprite.play("transformed_walk")
		else:
			if sprite.animation != "normal_walk":
				sprite.play("normal_walk")


func patrol():
	if motion.x == 0:
		reboot_horizontal_motion()
		
	restore_speed()
	
	horizontal_patrol()
