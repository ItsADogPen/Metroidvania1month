extends Enemy


	
func _physics_process(delta):
	move_gravity(delta)
	check_movement_direction()
	set_animation()
	
	if is_alive():
		if state == State.PATROL:
			patrol()
		elif state == State.CHASE:
			chase()
		elif state == State.ATTACK:
			pass
			
		motion = move_and_slide(motion, Vector2(0, 1), SLOPE_SLIDE_STOP)
		
#	set_orientation()
			
func set_orientation():
	if motion.x < 0:
		sprite.scale.x = -1
	elif motion.x > 0:
		sprite.scale.x = 1


func move_gravity(delta):
	if MAX_GRAVITY < 0:
		motion.y = max(motion.y + GRAVITY, MAX_GRAVITY)
	else:
		motion.y = min(motion.y + GRAVITY, MAX_GRAVITY)
	

	if MAX_GRAVITY <= 0:
		if rays.down.is_colliding():
			motion.y = ACCELERATION * 0.5
	else:
		if rays.up.is_colliding():
			motion.y = ACCELERATION * 0.5


	
	if !isAir:
		motion.y = 0

func check_movement_direction():
	
	if rays.left_corner.is_colliding() || rays.right_corner.is_colliding():
		isAir = false
	else:
		isAir = true

