extends Enemy


func _ready():
	attack_hit_boxes = {
		"normal": $NormalHitBox,
		"transformed_right": $TransformedHitBoxRight,
		"transformed_left": $TransformedHitBoxLeft,
		"transformed_total": $TransformedHitBoxTotal,
	}

func _physics_process(delta):
	if chasing:
		check_touch_damage()
	move_gravity(delta)
	check_movement_direction()
	set_animation()
	
	if not moves:
		motion.x = 0
	
	if is_alive():
		if state == State.PATROL:
			patrol()
		elif state == State.CHASE:
			chase()
		elif state == State.ATTACK:
			pass
		elif state == State.TRANSFORMING:
			pass
		elif state == State.DYING:
			pass
		motion = move_and_slide(motion, Vector2(0, -1), SLOPE_SLIDE_STOP)
		
	set_orientation()
	

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
	