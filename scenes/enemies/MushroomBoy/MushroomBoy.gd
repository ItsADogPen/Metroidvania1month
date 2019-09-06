extends "res://scenes/enemies/enemy.gd"


func _ready():
	
	randomize()
	set_physics_process(false)
	_initialize()
	set_physics_process(true)

func _initialize():
	stats.health = 10
	
	# random placement
	var math = [1,-1]
	var pick_math = math[randi()%math.size()]
	motion.x += (pick_math * (SPEED + ACCELERATION))


func _physics_process(delta):
	
	move_gravity(delta)
	check_movement_direction()
	
	if is_alive():
		movement()
		motion = move_and_slide(motion, UP, SLOPE_SLIDE_STOP)

func move_gravity(delta):
	
	motion.y = min(motion.y + GRAVITY, MAX_GRAVITY)
	
	if rays.up.is_colliding():
		motion.y = ACCELERATION * 0.5
	
	if !isAir:
		motion.y = 0

func check_movement_direction():
	
	if rays.left_corner.is_colliding() || rays.right_corner.is_colliding():
		isAir = false
	else:
		isAir = true


func movement():
	horizontal_patrol()
