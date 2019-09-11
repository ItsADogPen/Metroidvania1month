extends KinematicBody2D
class_name Player

# Signals
signal soul_gained
signal health_lost
signal reset_health

# Constants
const DASH_DIST = 450
const SLOPE_SLIDE_STOP = 4
const SNAP_DOWN = Vector2(0, 48)
const SNAP_ANGLE = 1.55
const FRIC = 1
const GRAV = 10
const GRAV_CAP = 1000

# Stats that can change with upgrades
var ACCEL = 500
var JUMP_SPEED = -325
var DOUBLE_JUMP_SPEED = (JUMP_SPEED * 0.925)
var WALL_JUMP_SPEED = JUMP_SPEED * -2

# Instance variables
var hp : int = 1
var hp_current : int = 1
var isDead : bool = false
var stateMachine : String = "idle"
var isAir : bool
var remaining_jumps : int = 2
var last_checkpoint
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
onready var side_ray_L = $Side_Ray_Left
onready var side_ray_R = $Side_Ray_Right
onready var dash_ray_L = $Dash_Check_Left
onready var dash_ray_R = $Dash_Check_Right

onready var ShieldScene = preload("res://src/player/skills/shield/Shield.tscn")
onready var map = get_parent()


func _ready():
	
	# Setup player stats
	hp = 4
	hp_current = hp
	
	# Create an initial point to teleport to on death
	var temp_checkpoint = Node2D.new()
	temp_checkpoint.position = position
	set_checkpoint(temp_checkpoint)
	
	# Connect signals to health bar
	var health_bar = get_node("/root/Game/UI/Overlay/HealthBar")
	connect("soul_gained", health_bar, "_on_soul_gained")
	connect("health_lost", health_bar, "_on_health_lost")
	connect("reset_health", health_bar, "_on_health_reset")

func _physics_process(delta):
	
	_gravity(delta)
	if is_on_floor():
		isAir = false
		_reset_jumps()
	else:
		isAir = true
	
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
		
	# Doesn't do the trick
	motion.y = max(motion.y, JUMP_SPEED)

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
	
	# Death animation
	isDead = true
	animation.play("die")
	yield(animation, "animation_finished")
	yield(get_tree().create_timer(0.6),"timeout")
	
	# Teleport player back to last checkpoint
	if last_checkpoint != null:
		position = last_checkpoint.position
	
	# Reset health and anim
	hp_current = hp
	animation.play("revive")
	yield(animation, "animation_finished")
	emit_signal("reset_health")
	isDead = false

func play_effect(effect: String):
	AudioEngine.play_positioned_effect(effect, self.global_position)

func _anim_Check():
	
	if isDead == false:
		
		if stateMachine == "attacking":
			animation.play("attackstab")
#			AudioEngine.play_positioned_effect("res://assets/audio/sfx/SFX_BladeAttack.ogg", self.global_position)
#			AudioEngine.play_effect("res://assets/audio/sfx/SFX_BladeAttack.ogg")
			hitbox_timer.start()
			
		elif stateMachine == "run":
			animation.offset.x = 0
#			if animation.scale.x == -1:
#				animation.offset.x = 15
			animation.play("run")
		elif stateMachine == "jump":
			animation.play("jump")
		elif stateMachine == "idle":
			animation.play("idle")
		elif stateMachine == "taking_damage":
			animation.play("damage")
	
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
	motion.x = (int(right) - int(left)) * SPEED
	
	if (right == left and not isAir):
		motion.x = 0
		if !stateMachine == "attacking" && !stateMachine == "dash" && !stateMachine == "shield" && !stateMachine == "taking_damage":
			stateMachine = "idle"
	else:
		SPEED = ACCEL
		if left || right:
			stateMachine = "run"
	
	motion.x = clamp(motion.x, -ACCEL, ACCEL)
	
	# === y movement ===
	if jump && remaining_jumps > 0:
		
		# Only jump if on ground or doublejumps are unlocked
		if not isAir or upgrades["double_jump"]:
			
			# If already in the air, only allow one jump
			remaining_jumps = 0 if isAir else 1
			isAir = true
			
			# Set speed depending on which jump this is
			if remaining_jumps == 1:
				motion.y = JUMP_SPEED
			else:
				motion.y = DOUBLE_JUMP_SPEED
		
	if isAir and stateMachine != "walljumping" and stateMachine != "taking_damage":
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
			play_effect("res://assets/audio/sfx/SFX_BladeAttack.ogg")
	
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
		stateMachine = "shield"
		print("SHIELD")
		animation.play("stabground-pre")
		yield(animation,"animation_finished")
		
		var load_shield = ShieldScene.instance()
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

func _attack_Machine():
	pass

func _on_AnimatedSprite_animation_finished():
	
	if animation.animation == "attackstab":
		
		stateMachine = "idle"

func _on_Hitbox_body_entered(body):
	if body.is_in_group("enemies"):
#		AudioEngine.effects.play_effect("strsgdsfg", body.global_position)
		body.take_damage(5)

func _on_AnimationPlayer_animation_finished(anim_name):
	
	anim_player.stop(true)
	stateMachine = "idle"
	print("anim_player STOPPED")

func _on_HitboxTimer_timeout():
	
	hitbox_shape.disabled = false
	yield(get_tree().create_timer(0.1),"timeout")
	hitbox_shape.disabled = true

# Triggers when a new upgrade is found
func unlock_upgrade(power_gained : String):
	
	print("Upgrade signal received for %s" % power_gained)
	
	if upgrades.has(power_gained):
		upgrades[power_gained] = true
		emit_signal("soul_gained", power_gained)
		
		# Implement passive upgrades and update UI
		match power_gained:
			"move_speed":
				ACCEL *= 1.333
			"jump_speed":
				JUMP_SPEED *= 1.25
				WALL_JUMP_SPEED *= 1.25
				DOUBLE_JUMP_SPEED *= 1.25
			"attack_speed":
				anim_player.playback_speed = 1.4
	
	else:
		print("Error: No such upgrade as %s" % power_gained)

# Called when player takes damage
func take_damage(damage : int):
	
	if stateMachine != "taking_damage":
		stateMachine = "taking_damage"
		
		emit_signal("health_lost", damage)
		hp_current -= damage
		if hp_current <= 0:
			_player_death()
		
		animation.set_self_modulate(Color(1, 0, 0, 0.7))
		yield(get_tree().create_timer(1.5), "timeout")
		stateMachine = "idle"
		animation.set_self_modulate(Color(1, 1, 1, 1))

func hit_spikes():
	take_damage(1)
	motion.y = JUMP_SPEED * 1.5
	motion = move_and_slide(motion, Vector2.UP, true)

func set_checkpoint(point):
	last_checkpoint = point

# DEBUG function to test upgrades
func toggle_upgrades():
	for key in upgrades.keys():
		unlock_upgrade(key)
