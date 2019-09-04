extends "res://scenes/enemies/TemplateAI.gd"

func _ready():
	
	randomize()
	
	set_physics_process(false)
	_initialize()
	_connect_Signals()
	set_physics_process(true)
	
	pass

func _initialize():
	
	hp = 10
	hp_current = hp
	
	SPEED = 0
	ACCEL = 200
	GRAV = 10
	GRAV_CAP = 1000
	
	var math = [1,-1]
	var pick_math = math[randi()%math.size()]
	
	motion.x += (pick_math * (SPEED+ACCEL))
	
	
	pass

func _physics_process(delta):
	
	_check_HP()
	_gravity(delta)
	_floor_Check()
	
	if isDead == false:
		_ai_Patrol()
		motion = move_and_slide(motion, UP, SLOPE_SLIDE_STOP)
	
	pass

func _gravity(delta):
	
	motion.y += GRAV
	
	if up_ray.is_colliding():
		motion.y = 0
		motion.y = ACCEL*0.5
	
	if motion.y > GRAV_CAP:
		motion.y = GRAV_CAP
	
	if !isAir:
		motion.y = 0
	
	pass

func _floor_Check():
	
	if corner_ray_L.is_colliding() || corner_ray_R.is_colliding():
		isAir = false
	else:
		isAir = true
	
	pass

func _ai_Patrol():
	
	
	if !corner_ray_R.is_colliding() || !corner_ray_L.is_colliding():
		
		var colli_math = int(corner_ray_R.is_colliding()) - int(corner_ray_L.is_colliding())
		
		motion.x = (motion.x)*colli_math
		
		pass
	
	if side_ray_R.is_colliding() || side_ray_L.is_colliding():
		
		var colli_math = int(side_ray_R.is_colliding()) - int(side_ray_L.is_colliding())
		
		motion.x = (motion.x)*colli_math
		
		pass
	
	
	pass