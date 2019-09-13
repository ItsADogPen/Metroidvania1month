extends Enemy



signal projectile

func _ready():
	attack_hit_boxes = {
		"normal": $NormalHitBox,
		"transformed_direct": $TransformedDirectHitBox,
		"transformed_spit": $TransformedSpitHitBox,
	}

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
		elif state == State.TRANSFORMING:
			pass
		elif state == State.DYING:
			pass
		motion = move_and_slide(motion, Vector2(0, -1), SLOPE_SLIDE_STOP)
		
	set_orientation()


func take_damage(damage: int):
	if invincible:
		return
		
	if is_alive() and state != State.TRANSFORMING:
		stats.health -= damage
		
		if not is_alive():
			if not stats.transformed and level == "Transform":
				_transform()
			else:
				_die()
				
func patrol():
	motion.x = 0
	
	
func chase():
	motion.x = 0
		
	
	# Attack logic will have to come in the attack function perhaps?
	if can_attack:
		if stats.transformed:
			if hit_detection_areas.transformed.overlaps_body(chasing):
				attack()
		else:
			if hit_detection_areas.normal.overlaps_body(chasing):
				attack()
	
func set_orientation():
	if chasing and not state == State.DYING:
		var direction = get_chasing_direction()
		if direction < 0:
			for area in hit_detection_areas.values():
				area.scale.x = 1
			for area in touch_damage_areas.values():
				area.scale.x = 1
			sprite.scale.x = 1
		elif direction > 0:
			for area in hit_detection_areas.values():
				area.scale.x = -1
			for area in touch_damage_areas.values():
				area.scale.x = -1
			sprite.scale.x = -1

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
		
		
func attack():
	if can_attack:
		state = State.ATTACK
		
		if stats.transformed:
			sprite.play("transformed_attack_direct")
		else:
			sprite.play("normal_attack_direct")
		yield(sprite, "animation_finished")
		play_attack_timer()
		
		if chasing:
			state = State.CHASE
		else:
			state = State.PATROL
	
	
func set_animation():	
	if state == State.PATROL or state == State.CHASE:
		if stats.transformed:
			if sprite.animation != "transformed_idle":
				sprite.play("transformed_idle")
		else:
			if sprite.animation != "normal_idle":
				sprite.play("normal_idle")
				
func shoot_projectile():
	if stats.transformed:
		emit_signal("projectile", "transformed")
	else:
		emit_signal("projectile", "normal")
