extends KinematicBody2D
class_name Player

# Signals
signal soul_gained
signal health_lost
signal reset_health
signal death

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
var JUMP_SPEED = -230
var DOUBLE_JUMP_SPEED = (JUMP_SPEED * 0.925)

onready var effect_player = AudioEngine.effects.effect_players[9]

# Instance variables
var hp : int = 1
var hp_current : int = 1
var isDead : bool = false

enum State {IDLE, RUN, ATTACK, JUMP, TAKE_DAMAGE, DYING, REVIVING, DIALOGUE, DASH}
var state = State.IDLE
var stateMachine : String = "idle"
var isAir : bool
var remaining_jumps : int = 2
var last_checkpoint
var SPEED = 0

var invincible = false

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
onready var animation_player = $AnimationPlayer
onready var sprites = $AnimatedSprite
onready var stab_hitbox = $StabHitbox

# Collision dection rays
onready var side_ray_L = $Side_Ray_Left
onready var side_ray_R = $Side_Ray_Right
onready var dash_ray_L = $Dash_Check_Left
onready var dash_ray_R = $Dash_Check_Right

onready var ShieldScene = preload("res://src/player/skills/shield/Shield.tscn")
onready var map = get_parent()

var jump_boosting = false
var jump_boost_speed = 0


func check_hit_enemies(hitbox: NodePath):
	print(hitbox)
	print(get_node(hitbox))
	for body in get_node(hitbox).get_overlapping_bodies():
		if body.is_in_group("enemies"):
			body.take_damage(5)

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
	
func start_dialogue():
	state = State.DIALOGUE

func end_dialogue():
	state = State.IDLE

func _physics_process(delta):
	if state == State.DASH:
		return
	
	_gravity(delta)
		
	if state == State.TAKE_DAMAGE:
		print("moving_with_motion", motion)
		motion = move_and_slide(motion, Vector2.UP, true)
		return
	if state == State.DIALOGUE:
		set_animation()
		motion.x = 0
		motion = move_and_slide(motion, Vector2.UP, true)
		return
	if state == State.ATTACK:
		return
	if state == State.DYING:
		motion.x = 0
		motion = move_and_slide(motion, Vector2.UP, true)
		return 
	if state == State.REVIVING:
		motion.x = 0
		motion = move_and_slide(motion, Vector2.UP, true)
		return
	
	if is_on_floor():
		isAir = false
		_reset_jumps()
	else:
		isAir = true
		
	if state == State.IDLE or state == State.RUN or state == State.JUMP:
		set_animation()
		set_orientation()
		process_controls(delta)
		
		motion = move_and_slide(motion, Vector2.UP, true)
	
	if Input.is_action_just_pressed("Death_Test_Button"):
		_player_death()
	
	if Input.is_action_just_pressed("ui_page_up"):
		toggle_upgrades()
		
	# Doesn't do the trick
	# motion.y = max(motion.y, JUMP_SPEED)

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
	
	# Death sprites

	state = State.DYING
	sprites.play("die")
	yield(sprites, "animation_finished")
	yield(get_tree().create_timer(1),"timeout")
	
	# Teleport player back to last checkpoint
	if last_checkpoint != null:
		position = last_checkpoint.position
	
	state = State.REVIVING
	# Reset health and anim
	hp_current = hp
	sprites.play("revive")
	yield(sprites, "animation_finished")
	emit_signal("death")
	emit_signal("reset_health")
	state = State.IDLE

func play_effect(effect: String):
	effect_player.play_effect(effect, global_position)

func set_animation():
	match state:
		State.DIALOGUE:
			if is_on_floor():
				sprites.play("idle")
		State.IDLE:
			sprites.play("idle")
		State.RUN:
			sprites.offset.x = 0
			sprites.play("run")
		State.JUMP:
			sprites.play("jump")

func set_orientation():
	if motion.x < 0:
		sprites.scale.x = -1
		stab_hitbox.scale.x = -1
		sprites.offset.x = 15
	if motion.x > 0:
		sprites.scale.x = 1
		stab_hitbox.scale.x = 1
		if sprites.offset.x != 0:
			sprites.offset.x = 0

func stop_hold_jump():
	jump_boosting = false
	
func _on_fall_jump():
	remaining_jumps = max(0, remaining_jumps - 1)

func process_controls(delta):
	# Get player input
	var left_pressed = Input.is_action_pressed("ui_left")
	var right_pressed = Input.is_action_pressed("ui_right")
	var jump_pressed = Input.is_action_just_pressed("jump")
	var jump_held = not jump_pressed and Input.is_action_pressed("jump")
	var stab_pressed = Input.is_action_just_pressed("basic_attack")
	var dash = Input.is_action_just_pressed("dash")
	var shield = Input.is_action_just_pressed("shield")
	
	# === x movement ===
	var speed_change = (int(right_pressed) - int(left_pressed)) * ACCEL * delta * 12
	if sign(motion.x) != sign(speed_change):
		motion.x = speed_change
	else:
		motion.x += speed_change
	
	if isAir and right_pressed == left_pressed:
		motion.x = 0
	if not isAir and right_pressed == left_pressed:
		motion.x = 0
		state = State.IDLE
	else:
		SPEED = ACCEL
		if (left_pressed or right_pressed) and not isAir:
			state = State.RUN
	
	motion.x = clamp(motion.x, -ACCEL, ACCEL)
	
	# === y movement ===
	if jump_pressed:
		if remaining_jumps > 0:
			jump_boosting = true
			if upgrades["double_jump"] and isAir:
				motion.y = DOUBLE_JUMP_SPEED
			else:
				motion.y = JUMP_SPEED
			remaining_jumps -= 1
			jump_boost_speed = motion.y
			get_tree().create_timer(0.45).connect("timeout", self, "stop_hold_jump")
			state = State.JUMP
			
	if jump_held:
		if jump_boosting:
			motion.y = jump_boost_speed
			
	# falling shortly allows a jump...
	if isAir and state != State.JUMP:
		state = State.JUMP
		get_tree().create_timer(0.1).connect("timeout", self, "_on_fall_jump")

	"""
	if jump_pressed && remaining_jumps > 0:
		
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
	"""
	
	if state == State.IDLE or state == State.RUN:
		if stab_pressed:
			stab()
	
	# Handle dashing
	if dash and upgrades["dash"]:
		dash()
	
	# Handle shield move
#	if shield and upgrades["shield_aoe"]:
#		stateMachine = "shield"
#		print("SHIELD")
#		sprites.play("stabground-pre")
#		yield(sprites,"animation_finished")
#
#		var load_shield = ShieldScene.instance()
#		map.projectiles_container.add_child(load_shield)
#		load_shield.global_position = self.global_position
#		yield(get_tree().create_timer(0.2),"timeout")
#		load_shield._play_Anim("beginning")
#
#		sprites.play("stabground-loop")
#		yield(get_tree().create_timer(2),"timeout")
#		sprites.play("stabground-end")
#		load_shield._play_Anim("end")
#		yield(sprites,"animation_finished")
#		load_shield._destroy()
#		stateMachine = "idle"
	
	motion.normalized()
	
func dash():
	state = State.DASH
	sprites.play("dash-pre")
	yield(sprites,"animation_finished")
	
	var ray_checkers = [dash_ray_L,dash_ray_R]
	for i in ray_checkers: i.enabled = true
	
	if ray_checkers[0].is_colliding() && sprites.scale.x == -1:
		
		var colli_point = ray_checkers[0].get_collision_point()
		global_position = colli_point
		
	elif !ray_checkers[0].is_colliding() && sprites.scale.x == -1:
		
		var math_vector = Vector2()
		math_vector.x = (math_vector.x+DASH_DIST)*-1
		
		global_position = global_position + math_vector
		
	elif ray_checkers[1].is_colliding() && sprites.scale.x == 1:
		
		var colli_point = ray_checkers[1].get_collision_point()
		global_position = colli_point
		
	elif !ray_checkers[1].is_colliding() && sprites.scale.x == 1:
		
		var math_vector = Vector2()
		math_vector.x = math_vector.x + DASH_DIST
		
		global_position = global_position + math_vector
		
	elif !ray_checkers[0].is_colliding() && !ray_checkers[1].is_colliding():
		
		var facing = sprites.scale.x
		
		var math_vector = Vector2()
		math_vector.x = math_vector.x+DASH_DIST
		math_vector.x = (math_vector.x)*facing
		
		global_position = global_position + math_vector
	
	sprites.play("dash-post")
	yield(sprites,"animation_finished")
	state = State.IDLE

func stab():
	animation_player.play("stab")
	state = State.ATTACK
	yield(animation_player, "animation_finished")
	if state == State.ATTACK:
		state = State.IDLE

func take_damage_animation():
	animation_player.play("take_damage")
	state = State.TAKE_DAMAGE

func _gravity(delta):
	motion.y += GRAV
	if motion.y > GRAV_CAP:
		motion.y = GRAV_CAP

func _attack_Machine():
	pass

func _on_AnimatedSprite_animation_finished():
	
	if sprites.animation == "attackstab":
		
		stateMachine = "idle"


func _on_AnimationPlayer_animation_finished(anim_name):
	
	animation_player.stop(true)
	stateMachine = "idle"
	print("animation_player STOPPED")

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
				DOUBLE_JUMP_SPEED *= 1.25
			"attack_speed":
				animation_player.playback_speed = 1.4
	
	else:
		print("Error: No such upgrade as %s" % power_gained)

func can_not_take_damage():
	return invincible or state == State.DYING or state == State.REVIVING or state == State.DIALOGUE

# Called when player takes damage
func take_damage(damage : int):
	if can_not_take_damage():
		return
	# if stateMachine != "taking_damage":
	# 	stateMachine = "taking_damage"
		
	emit_signal("health_lost", damage)
	hp_current -= damage
	if hp_current <= 0:
		_player_death()
	else:
		state = State.TAKE_DAMAGE
		$AnimatedSprite.material = load("res://src/player/shader.tres")
		invincible = true
		sprites.play("damage")
		yield(get_tree().create_timer(0.45), "timeout")
		state = State.IDLE
		yield(get_tree().create_timer(0.6), "timeout")
		invincible = false
		$AnimatedSprite.material = null

func take_enemy_damage(damage: int):
	if not can_not_take_damage():
		print("Taking enemy damage...")
		if animation_player.is_playing():
			animation_player.stop(true)
		take_damage(damage)
		var direction = sprites.scale.x
		motion.y = -120
		motion.x = direction * -80
		print("motion in function", motion)
		motion = move_and_slide(motion, Vector2.UP, true)

func hit_spikes():
	if not can_not_take_damage():
		take_damage(1)
		var direction = sprites.scale.x
		motion.y = -120
		motion.x = direction * -80
		print("motion in function", motion)
		motion = move_and_slide(motion, Vector2.UP, true)

func set_checkpoint(point):
	last_checkpoint = point

# DEBUG function to test upgrades
func toggle_upgrades():
	for key in upgrades.keys():
		unlock_upgrade(key)


