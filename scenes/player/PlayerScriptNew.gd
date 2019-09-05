extends KinematicBody2D
class_name Player

# Constants
const ACCEL = 900
const ACCEL_UPGRADE = 1200
const DASH_DIST = 450
const SLOPE_SLIDE_STOP = 4
const SNAP_DOWN = Vector2(0, 16)
const SNAP_ANGLE = 0.89
const FRIC = 1
const GRAV = 10
const GRAV_CAP = 1000
const JUMP_SPEED = -400
const JUMP_UPGRADE_SPEED = -200
const DOUBLE_JUMP_SPEED = (JUMP_SPEED * 0.925)
const WALL_JUMP_SPEED = JUMP_SPEED * -2

# Instance variables
var hp : int = 1
var hp_current : int = 1
var isDead : bool = false
var stateMachine : String = "idle"
var isAir : bool
var remaining_jumps : int = 2
var SPEED = 0

# Upgrades the player can collect over time
var upgrades = {
	"double_jump" : false,
	"jump_speed" : false,
	"move_speed" : false,
	"attack_speed" : false,
	"attack_aoe" : false,
	"shield_aoe" : false,
	"dash" : false
}

# Player sprite elements
var motion: Vector2 = Vector2()
onready var anim_player = $AnimationPlayer
onready var animation = $AnimatedSprite
onready var hitbox = $Hitbox
onready var hitbox_shape = $Hitbox/CollisionShape2D
onready var hitbox_timer = $HitboxTimer

# Collision dection rays
onready var floor_ray = $Floor_Ray
onready var corner_ray_L = $Corner_Ray_Left
onready var corner_ray_R = $Corner_Ray_Right
onready var up_ray = $Up_Ray
onready var side_ray_L = $Side_Ray_Left
onready var side_ray_R = $Side_Ray_Right
onready var dash_ray_L = $Dash_Check_Left
onready var dash_ray_R = $Dash_Check_Right

onready var map = get_parent()

func _ready():
	
	hp = 10
	hp_current = hp

func _physics_process(delta):
	
	_floor_Check()
	_gravity(delta)
	
	if isDead == false:
		_anim_Check()
		_controls(delta)
		
		if stateMachine == "jump":
			motion = move_and_slide(motion, Vector2.UP, true)
		else:
			motion = move_and_slide_with_snap(motion, SNAP_DOWN, Vector2.UP, true, SLOPE_SLIDE_STOP, SNAP_ANGLE)
	
	if Input.is_action_just_pressed("Death_Test_Button"):
		_player_death()
	
	if Input.is_action_just_pressed("ui_page_up"):
		toggle_upgrades()

func _check_HP():
	
	if hp_current <= 0:
		_player_death()

# Reset the number of jumps the player has, called when player hits floor
func _reset_jumps():
	if upgrades["double_jump"]:
		remaining_jumps = 2
	else:
		remaining_jumps = 1

func _player_death():
	
	isDead = true
	animation.play("die")
	yield(animation, "animation_finished")
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
	
	# Get player input
	var left = Input.is_action_pressed("ui_left")
	var right = Input.is_action_pressed("ui_right")
	var jump = Input.is_action_just_pressed("jump")
	var attack_button = Input.is_action_just_pressed("basic_attack")
	var dash = Input.is_action_just_pressed("dash")
	var shield = Input.is_action_just_pressed("shield")
	
	# === x movement ===
	motion.x += (int(right) - int(left)) * SPEED
	
	if (right == left and not isAir):
		motion.x = 0
		if !stateMachine == "attacking" && !stateMachine == "dash" && !stateMachine == "shield":
			stateMachine = "idle"
	else:
		SPEED = ACCEL + (int(upgrades["move_speed"]) * ACCEL_UPGRADE)
		if left || right:
			stateMachine = "run"
	
	if upgrades["move_speed"]:
		motion.x = clamp(motion.x, -ACCEL_UPGRADE, ACCEL_UPGRADE)
	else:
		motion.x = clamp(motion.x, -ACCEL, ACCEL)
	
	# === y movement ===
	if jump && remaining_jumps > 0:
		remaining_jumps -= 1
		isAir = true
		
		# Set speed depending on which jump this is
		if remaining_jumps == 1:
			motion.y = JUMP_SPEED + (int(upgrades["jump_speed"]) * JUMP_UPGRADE_SPEED)
		else:
			motion.y = DOUBLE_JUMP_SPEED + (int(upgrades["jump_speed"]) * JUMP_UPGRADE_SPEED)
	
	if isAir and stateMachine != "walljumping":
		stateMachine = "jump"
	
	# Handle wall jumping
	if isAir and jump:
		
		if side_ray_L.is_colliding() && right:
			stateMachine = "walljumping"
			motion.y = JUMP_SPEED
			motion.x += WALL_JUMP_SPEED
		
		elif side_ray_R.is_colliding() && left:
			stateMachine = "walljumping"
			motion.y = JUMP_SPEED
			motion.x -= WALL_JUMP_SPEED
		
		if stateMachine != "walljumping":
			stateMachine = "jump"
	
	if !stateMachine == "dash" || !stateMachine == "shield":
		if attack_button && !isAir && !stateMachine == "run":
			stateMachine = "attacking"
			print(stateMachine)
	
	# Handle dashing
	if dash and upgrades["dash"]:
		
		stateMachine = "dash"
		animation.play("dash-pre")
		yield(animation,"animation_finished")
		
		var ray_checkers = [dash_ray_L,dash_ray_R]
		for i in ray_checkers: i.enabled = true
		
		if ray_checkers[0].is_colliding() && animation.scale.x == -1:
			
			var colli_point = ray_checkers[0].get_collision_point()
			global_position = colli_point
			
		elif !ray_checkers[0].is_colliding() && animation.scale.x == -1:
			
			var math_vector = Vector2()
			math_vector.x = (math_vector.x+DASH_DIST)*-1
			
			global_position = global_position + math_vector
			
		elif ray_checkers[1].is_colliding() && animation.scale.x == 1:
			
			var colli_point = ray_checkers[1].get_collision_point()
			global_position = colli_point
			
		elif !ray_checkers[1].is_colliding() && animation.scale.x == 1:
			
			var math_vector = Vector2()
			math_vector.x = math_vector.x + DASH_DIST
			
			global_position = global_position + math_vector
			
		elif !ray_checkers[0].is_colliding() && !ray_checkers[1].is_colliding():
			
			var facing = animation.scale.x
			
			var math_vector = Vector2()
			math_vector.x = math_vector.x+DASH_DIST
			math_vector.x = (math_vector.x)*facing
			
			global_position = global_position + math_vector
		
		animation.play("dash-post")
		yield(animation,"animation_finished")
		stateMachine = "idle"
	
	# Handle shield move
	if shield and upgrades["shield_aoe"]:
		
		var preload_shield = ProjectilesPreloader._return_Resource("ProjectileShield")
		
		stateMachine = "shield"
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
		stateMachine = "idle"
	
	motion.normalized()

func _gravity(delta):
	
	motion.y += GRAV
	if motion.y > GRAV_CAP:
		motion.y = GRAV_CAP

func _floor_Check():
	
	if corner_ray_L.is_colliding() || corner_ray_R.is_colliding():
		isAir = false
		_reset_jumps()
	else:
		isAir = true

func _attack_Machine():
	pass

func _on_AnimatedSprite_animation_finished():
	
	if animation.animation == "attackstab":
		
		stateMachine = "idle"

func _on_Hitbox_body_entered(body):
	if body.is_in_group("enemies"):
		body.hp_current -= 5

func _on_AnimationPlayer_animation_finished(anim_name):
	
	anim_player.stop(true)
	stateMachine = "idle"
	print("anim_player STOPPED")

func _on_HitboxTimer_timeout():
	
	hitbox_shape.disabled = false
	yield(get_tree().create_timer(0.1),"timeout")
	hitbox_shape.disabled = true

# DEBUG function to test upgrades
func toggle_upgrades():
	var new_value = not upgrades["double_jump"]
	print("Setting all player upgrades to %s..." % str(new_value))
	for key in upgrades.keys():
		upgrades[key] = new_value
