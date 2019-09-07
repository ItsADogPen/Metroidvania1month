extends Enemy


func _physics_process(delta):
	move_gravity(delta)
	check_movement_direction()
	
	if is_alive():
		movement()
		motion = move_and_slide(motion, Vector2(0, -1), SLOPE_SLIDE_STOP)

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
	if motion.x == 0:
		reboot_horizontal_motion()
		
	restore_speed()
	
	horizontal_patrol()
