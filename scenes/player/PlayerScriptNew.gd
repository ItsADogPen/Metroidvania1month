extends KinematicBody2D
class_name Player

## Stat Variables ###
var hp : int = 1
var hp_current : int = 1
var isDead : bool = false
var canDoubleJump : bool = false
#####################


var motion: Vector2 = Vector2()
onready var anim_player = $AnimationPlayer
onready var animation = $AnimatedSprite
onready var floor_ray = $Floor_Ray
onready var corner_ray_L = $Corner_Ray_Left
onready var corner_ray_R = $Corner_Ray_Right
onready var up_ray = $Up_Ray
onready var side_ray_L = $Side_Ray_Left
onready var side_ray_R = $Side_Ray_Right
onready var dash_ray_L = $Dash_Check_Left
onready var dash_ray_R = $Dash_Check_Right
onready var hitbox = $Hitbox
onready var hitbox_shape = $Hitbox/CollisionShape2D
onready var hitbox_timer = $HitboxTimer

onready var map = get_parent()

var stateMachine : String = "idle"
var isAir : bool
var isWall = [false, "none"]

const UP = Vector2(0,-1)
var ACCEL = 900
var SPEED = 0
var dash_distance = 450
const SLOPE_SLIDE_STOP = 640
const FRIC = 1
const GRAV = 10
const GRAV_CAP = 1000
const JUMP_SPEED = -400
const DOUBLE_JUMP_SPEED = (JUMP_SPEED*0.925)
const WALL_JUMP_SPEED = JUMP_SPEED*2


func _ready():
	
	hp = 10
	hp_current = hp

func _physics_process(delta):
	
	_floor_Check()
	_gravity(delta)
	_wall_Check()
	
	if isDead == false:
		_anim_Check()
		_controls(delta)
		motion = move_and_slide(motion, UP, SLOPE_SLIDE_STOP)
	
	if Input.is_action_just_pressed("Death_Test_Button"):
		_die("die")

func _check_HP():
	
	if hp_current <= 0:
		_die("die")

func _die(die_anim : String):
	
	isDead = true
	animation.play(die_anim)
	yield(animation,"animation_finished")
	yield(get_tree().create_timer(0.35),"timeout")
	print("DED")

func _anim_Check():
	
	if isDead == false:
		
		if stateMachine == "attacking":
			animation.play("attackstab")
			hitbox_timer.start()
			
		if stateMachine == "run":
			animation.offset.x = 0
#			if animation.scale.x == -1:
#				animation.offset.x = 15
			animation.play("run")
		if stateMachine == "jump":
			animation.play("jump")
		if stateMachine == "idle":
			animation.play("idle")
	
	
	if motion.x < 0:
		animation.scale.x = -1
		hitbox.scale.x = -1
		animation.offset.x = 15
	if motion.x > 0:
		animation.scale.x = 1
		hitbox.scale.x = 1
		if animation.offset.x != 0:
			animation.offset.x = 0

func _controls(delta):
	
	var left = Input.is_action_pressed("ui_left")
	var right = Input.is_action_pressed("ui_right")
	var jump = Input.is_action_just_pressed("jump")
	var attack_button = Input.is_action_just_pressed("basic_attack")
	var dash = Input.is_action_just_pressed("dash")
	var shield = Input.is_action_just_pressed("shield")
	
	
	# === x movement ===
	
	motion.x += (int(right) - int(left))*SPEED
	
	if ((right&&left) && isAir == false) || ((!right && !left) && isAir == false):
		motion.x = 0
		if !stateMachine == "attacking" && !stateMachine == "dash" && !stateMachine == "shield":
			_state_Machine("idle")
	else:
		SPEED = ACCEL
		if left || right:
			_state_Machine("run")
	
	if motion.x < -ACCEL:
		motion.x = -ACCEL
	elif motion.x > ACCEL:
		motion.x = ACCEL
	
	
	# === y movement ===
	
	if isAir == false:
		
		canDoubleJump = false
		
		if jump:
			
			motion.y = JUMP_SPEED
	
	if isAir == true:
		
		canDoubleJump = true
		
		if stateMachine != "walljumping":
			_state_Machine("jump")
		
		if jump && canDoubleJump:
			
			motion.y = DOUBLE_JUMP_SPEED
			
			pass
	
#	if isAir == true:
#
#		if jump && isWall[0] == true:
#
#			if isWall[1] == "left" && right:
#
#				_state_Machine("walljumping")
#				motion.y = JUMP_SPEED
#				motion.x += WALL_JUMP_SPEED
#
#			elif isWall[1] == "right" && left:
#
#				_state_Machine("walljumping")
#				motion.y = JUMP_SPEED
#				motion.x -= WALL_JUMP_SPEED
#
#			print("WALL JUMPING AYY LMAO")
#
#		if stateMachine != "walljumping":
#			_state_Machine("jump")
#
	
	if !stateMachine == "dash" || !stateMachine == "shield":
		if attack_button && !isAir && !stateMachine == "run":
			_state_Machine("attacking")
			print(stateMachine)
	
	if dash:
		
		_state_Machine("dash")
		animation.play("dash-pre")
		yield(animation,"animation_finished")
		
		
		var ray_checkers = [dash_ray_L,dash_ray_R]
		for i in ray_checkers: i.enabled = true
		
		if ray_checkers[0].is_colliding() && animation.scale.x == -1:
			
			var colli_point = ray_checkers[0].get_collision_point()
			global_position = colli_point
			
		elif !ray_checkers[0].is_colliding() && animation.scale.x == -1:
			
			var math_vector = Vector2()
			math_vector.x = (math_vector.x+dash_distance)*-1
			
			global_position = global_position + math_vector
			
		elif ray_checkers[1].is_colliding() && animation.scale.x == 1:
			
			var colli_point = ray_checkers[1].get_collision_point()
			global_position = colli_point
			
		elif !ray_checkers[1].is_colliding() && animation.scale.x == 1:
			
			var math_vector = Vector2()
			math_vector.x = math_vector.x + dash_distance
			
			global_position = global_position + math_vector
			
		elif !ray_checkers[0].is_colliding() && !ray_checkers[1].is_colliding():
			
			var facing = animation.scale.x
			
			var math_vector = Vector2()
			math_vector.x = math_vector.x+dash_distance
			math_vector.x = (math_vector.x)*facing
			
			global_position = global_position + math_vector
			
		
		animation.play("dash-post")
		yield(animation,"animation_finished")
		_state_Machine("idle")
		
		pass
	
	if shield:
		
		var preload_shield = ProjectilesPreloader._return_Resource("ProjectileShield")
		
		_state_Machine("shield")
		print("SHIELD")
		animation.play("stabground-pre")
		yield(animation,"animation_finished")
		
		var load_shield = preload_shield.instance()
		map.projectiles_container.add_child(load_shield)
		load_shield.global_position = self.global_position
		yield(get_tree().create_timer(0.2),"timeout")
		load_shield._play_Anim("beginning")
		
		animation.play("stabground-loop")
		yield(get_tree().create_timer(2),"timeout")
		animation.play("stabground-end")
		load_shield._play_Anim("end")
		yield(animation,"animation_finished")
		load_shield._destroy()
		_state_Machine("idle")
		
		pass
	
	motion.normalized()

func _state_Machine(arg1):
	
	# Pass a String into arg1 to modify state of stateMachine
	#i.e. arg1 == "run": stateMachine = "run"
	#
	stateMachine = arg1

func _gravity(delta):
	
	var jump = Input.is_action_just_pressed("jump")
	
	motion.y += GRAV
	
	if up_ray.is_colliding():
		motion.y = 0
		motion.y = ACCEL*0.5
	
	if motion.y > GRAV_CAP:
		motion.y = GRAV_CAP
	
	if !isAir && !jump:
		motion.y = 0

func _floor_Check():
	
	if corner_ray_L.is_colliding() || corner_ray_R.is_colliding():
		isAir = false
	else:
		isAir = true

func _wall_Check():
	
	if !side_ray_R.is_colliding() && !side_ray_L.is_colliding():
		isWall[0] = false
		isWall[1] = "none"
	
	if side_ray_R.is_colliding() || side_ray_L.is_colliding():
		
		
		isWall[0] = true
		var math = (int(side_ray_R.is_colliding()) - int(side_ray_L.is_colliding()))
		
		if math > 0:
			isWall[1] = "right"
		elif math < 0:
			isWall[1] = "left"
		
		pass

func _attack_Machine():
	pass

func _on_AnimatedSprite_animation_finished():
	
	if animation.animation == "attackstab":
		
		_state_Machine("idle")
		
		pass

func _on_Hitbox_body_entered(body):
	if body.is_in_group("enemies"):
		body.hp_current -= 5

func _activate_Attack_Hitbox():
	
	hitbox_shape.disabled = false

func _deactivate_Hitbox():
	
	hitbox_shape.disabled = true

func _on_AnimationPlayer_animation_finished(anim_name):
	
	anim_player.stop(true)
	_state_Machine("idle")
	print("anim_player STOPPED")


func _on_HitboxTimer_timeout():
	
	hitbox_shape.disabled = false
	yield(get_tree().create_timer(0.1),"timeout")
	hitbox_shape.disabled = true
