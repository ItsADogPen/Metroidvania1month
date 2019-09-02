extends KinematicBody2D

var motion: Vector2 = Vector2()
onready var anim_player = $AnimationPlayer


const FLOOR: Vector2 = Vector2(0, -1)
const SLOPE_SLIDE_STOP := 5.0
const ACC := 60
const SPEED := 400
const FRIC := 1
const GRAV := 800
const GRAV_CAP := 1050
const JUMP_SPEED := 400
const DOUBLE_JUMP_SPEED := -350

func _physics_process(delta:float) -> void:
	state_base(delta)
	visuals()


func state_base(delta):
	player_control(delta)

func state_attack():
	pass

func player_control(delta:float) -> void:
	controls_logic(delta)
	collisions_and_rays()

func visuals():
	sprite_dir()

var jumping = false
var on_ground = false

var snap = Vector2(0,32)

func controls_logic(delta):
	
	if Input.is_action_pressed("ui_right") && !Input.is_action_pressed("ui_left"):
		motion.x = SPEED
	elif Input.is_action_pressed("ui_left") && !Input.is_action_pressed("ui_right"):
		motion.x = -SPEED
	else:
		motion.x = 0
	
	if !on_floor():
		motion.y += GRAV * delta
		if motion.y > GRAV_CAP:
			motion.y = GRAV_CAP
	
	if on_floor():
		on_ground = true
		motion.y = 0
	
	if on_floor() and Input.is_action_just_pressed("jump"):
		motion.y = -JUMP_SPEED
		jumping = true
	
	if jumping and motion.y > 0:
		jumping = false
	
	
	if jumping:
		snap = Vector2()
		
	move_and_slide_with_snap(motion, FLOOR, snap)
	print(motion.y)
	
func on_floor():
	return $Floor_Ray.is_colliding()


func collisions_and_rays():
	if Input.is_action_pressed("ui_right"):
		$CollisionShape2D.position.x = 2
		$Hitbox/Collider.position.x = 2
		
		$Floor_Ray.position.x = 0
		
	if Input.is_action_pressed("ui_left"):
		$CollisionShape2D.position.x = -21
		$Hitbox/Collider.position.x = -20
		
		$Floor_Ray.position.x = -20
		
		

func sprite_dir():
	if motion.x > 0:
		$Sprite.flip_h = false
	if motion.x < 0:
		$Sprite.flip_h = true
