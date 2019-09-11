extends KinematicBody2D
class_name Enemy


const UP = Vector2(0, -1)


export(String, "Regular", "Transform", "Monster") var level

enum State {IDLE, PATROL, CHASE, ATTACK, TAKE_DAMAGE, TRANSFORMING, DYING, TAKE_DAMAGE}

export(bool) var invincible = false
export(int) var REGULAR_HEALTH = 10
export(int) var MONSTER_HEALTH = 20

export (int) var REGULAR_ATTACK = 1
export (int) var MONSTER_ATTACK = 2

export(bool) var moves = true

export(float) var REGULAR_ATTACK_COOLDOWN = 1.0
export(float) var MONSTER_ATTACK_COOLDOWN = 1.0

export var ACCELERATION = 200
export var SPEED = 0
export var FRICTION = 0
export var GRAVITY = 10
export var MAX_GRAVITY = 1000

var state = State.PATROL

var can_attack: bool = true

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

onready var hit_detection_areas = {
	"normal": $AttackDetectionArea,
	"transformed": $TransformedAttackDetectionArea
}

onready var touch_damage_areas = {
	"normal": $NormalTouchDamageArea,
	"transformed": $TransformedTouchDamageArea
}

onready var attack_hit_boxes = {
}

onready var attack_timer = $AttackTimer as Timer

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
	stats.health = REGULAR_HEALTH
	
	attack_timer.connect("timeout", self, "_on_attack_timer_timeout")
	touch_damage_areas["normal"].connect("body_entered", self, "_on_normal_attack_hit")
	touch_damage_areas["transformed"].connect("body_entered", self, "_on_monster_attack_hit")
	
	for child in touch_damage_areas["transformed"].get_children():
		if child is CollisionShape2D: child.set_disabled(true)
	
	if level == "Monster":
		_transform()
		
	randomize()
	set_physics_process(false)
	_initialize()
	set_physics_process(true)
	
func _on_attack_timer_timeout():
	can_attack = true

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
	
	
func _initialize():
	if level == "Monster":
		stats.health = MONSTER_HEALTH
	else:
		stats.health = REGULAR_HEALTH
	
	# random placement
	reboot_horizontal_motion()

func take_damage(damage: int):
	print(damage)
	if invincible:
		return
		
	if is_alive() and state != State.TRANSFORMING:
		stats.health -= damage
		
		if not is_alive():
			if not stats.transformed and level == "Transform":
				_transform()
			else:
				_die()
		else:
			if state != State.ATTACK:
				motion.x = 0
				state = State.TAKE_DAMAGE
				if stats.transformed:
					sprite.play("transformed_take_damage")
				else:
					sprite.play("normal_take_damage")
				yield(sprite, "animation_finished")
				
				if chasing:
					state = State.CHASE
				else:
					state = State.PATROL

func play_attack_timer():
	can_attack = false
	if stats.transformed:
		# adds small randomness to boss timer
		var timeout = MONSTER_ATTACK_COOLDOWN * (1 + (-0.5 + randf()) * 0.1)
		attack_timer.start(timeout)
	else:
		# adds small randomness to boss timer
		var timeout = REGULAR_ATTACK_COOLDOWN * (1 + (-0.5 + randf()) * 0.1)
		attack_timer.start(timeout)

func _transform():
	motion.x = 0
	state = State.TRANSFORMING
	stats.health = MONSTER_HEALTH
	stats.transformed = true
	sprite.play("transformation")
	yield(sprite, "animation_finished")
	for child in touch_damage_areas["normal"].get_children():
		if child is CollisionShape2D:
			child.set_disabled(true)
	for child in touch_damage_areas["transformed"].get_children():
		if child is CollisionShape2D:
			child.set_disabled(false)
	if chasing:
		state = State.CHASE
	else:
		state = State.PATROL


func _die():
	$CollisionShape2D.shape = null
	for touch_damage_area in touch_damage_areas.values():
		for child in touch_damage_area.get_children():
			if child is CollisionShape2D:
				child.set_disabled(true)
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
	
	if stats.transformed:
		if hit_detection_areas.transformed.overlaps_body(chasing):
			attack()
	else:
		if hit_detection_areas.normal.overlaps_body(chasing):
			attack()
	
func attack():
	if can_attack:
		motion.x = 0
		
		state = State.ATTACK
		
		if stats.transformed:
			animation_player.play("transformed_attack")
		else:
			animation_player.play("normal_attack")
		yield(animation_player, "animation_finished")
		play_attack_timer()
		
		if chasing:
			state = State.CHASE
		else:
			state = State.PATROL

func _on_normal_attack_hit(body):
	if not stats.transformed and state != State.DYING:
		if body is Player:
			body.take_damage(REGULAR_ATTACK)

func _on_monster_attack_hit(body):
	if stats.transformed and state != State.DYING:
		if body is Player:
			body.take_damage(MONSTER_ATTACK)

func set_animation():
	if state == State.PATROL or state == State.CHASE:
		if stats.transformed:
			if sprite.animation != "transformed_walk":
				sprite.play("transformed_walk")
		else:
			if sprite.animation != "normal_walk":
				sprite.play("normal_walk")
	elif state == State.IDLE:
		if stats.transformed:
			if sprite.animation != "transformed_idle":
				sprite.play("transformed_idle")
		else:
			if sprite.animation != "normal_idle":
				sprite.play("normal_idle")

func set_orientation():
	if motion.x < 0:
		for area in hit_detection_areas.values():
			area.scale.x = -1
		for area in touch_damage_areas.values():
			area.scale.x = -1
		for area in attack_hit_boxes.values():
			area.scale.x = -1
		sprite.scale.x = -1
	elif motion.x > 0:
		for area in hit_detection_areas.values():
			area.scale.x = 1
		for area in touch_damage_areas.values():
			area.scale.x = 1
		for area in attack_hit_boxes.values():
			area.scale.x = 1
		sprite.scale.x = 1


func patrol():
	if motion.x == 0:
		reboot_horizontal_motion()
		
	restore_speed()
	
	horizontal_patrol()


func check_hit_player(hitbox: NodePath):
	if chasing:
		print(get_node(hitbox))
		if get_node(hitbox).overlaps_body(chasing):
			chasing.take_damage(1)