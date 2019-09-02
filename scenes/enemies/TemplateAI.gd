extends KinematicBody2D

## Stat Variables ###
var hp : int = 1
var hp_current : int = 1

#####################

## Vector Variables and ETC ##
var motion: Vector2 = Vector2()
const UP = Vector2(0,-1)
var ACCEL
var SPEED
var FRIC
var GRAV
var GRAV_CAP

var isAir : bool
var isWall = [false, "none"]
var stateMachine : String = "idle"

const SLOPE_SLIDE_STOP = 640


## Nodes variables ##
onready var anim_player = $AnimationPlayer
onready var animation = $AnimatedSprite
onready var floor_ray = $Floor_Ray
onready var corner_ray_L = $Corner_Ray_Left
onready var corner_ray_R = $Corner_Ray_Right
onready var up_ray = $Up_Ray
onready var side_ray_L = $Side_Ray_Left
onready var side_ray_R = $Side_Ray_Right
onready var detection_rad = $Detection2D


#=== AI Variables ===
var ai_patrol_dist

#func _physics_process(delta):
#
##	_check_HP()
#
#	motion = move_and_slide(motion, UP, SLOPE_SLIDE_STOP)
#
#	pass

func _initialize():  # OVERRIDE THIS IN EACH INDIVIDUAL ENEMY AI
	
	pass

func _modify_HP(damage:int):
	
	hp_current = hp_current - damage
	
	pass

func _check_HP():
	
	if hp_current <= 0:
		_die("die")
	
	
	pass

func _die(die_anim : String):
	
	animation.play("die")
	yield(animation,"animation_finished")
	yield(get_tree().create_timer(0.35),"timeout")
	self.queue_free()
	
	pass

func _connect_Signals():
	
	detection_rad.connect("body_entered",self,"_ai_Detect")
	
	
	pass

########################################
#ALL AI LOGICS BELOW SHOULD ONLY BE OVERIDDEN AND CODED IN INDIVIDUAL ENEMY AI. THIS IS JUST A TEMPLATE THAT WILL INTERACT WITH VARIOUS FUNCTIONS
#FROM ABOVE
########################################

func _ai_Patrol():
	
	# Patrol for when enemy behaviour requires a set or randomized movement over time repeatedly
	
	# set current position and get another position
	# move character to position
	# reverse logic to move character back
	# repeat
	
	
	pass

func _ai_Detect(body):
	
	# for working with detection_rad of Class.Area2D
	
	print(body.get_name())
	
	
	
	pass

func _ai_Attack_Machine():
	
	# for behaviour related to active actions
	
	pass
