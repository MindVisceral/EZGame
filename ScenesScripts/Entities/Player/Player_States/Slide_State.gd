extends BasePlayerState

@export_group("Movement")
#
## Time for the Player to reach full speed
## 60 and above is pretty much instant movement, but keep below 110 because of stuttering
@export_range(10.0, 110.0, 1.0) var acceleration: float = 60.0
## Time for the Player to stop in place
@export_range(10.0, 110.0, 1.0) var deceleration: float = 60.0
## Speed while in this state
@export_range(0.1, 2.0, 0.05) var speed_multiplier: float = 1.5
## % of player.speed used in sideways movement calculations
@export_range(0.1, 2.0, 0.05) var sideways_speed_multiplier: float = 0.4


@export_group("States")
#
@export var idle_state: BasePlayerState
@export var walk_state: BasePlayerState
@export var jump_state: BasePlayerState
@export var fall_state: BasePlayerState


## This holds the direction in which the Player will slide for the duration of this slide.
## Set by calculate_slide_direction()
var slide_direction: Vector3 = Vector3.ZERO


func enter() -> void:
	super.enter()
	
	## We must detect walls to stop the Player when they collide with one at certain angles
	player.WallDetection.enabled = true
	
	## Alter the height to crouch height
	player.HeightAlternator.alter_collider_height(player.crouch_height)
	## Disable headbobbing while sliding
	player.headbob_active = false
	
	## We want the Player to slide in the direction they are looking in,
	## at the moment of entering the slide state
	slide_direction = calculate_slide_direction()
	player.direction = slide_direction

func exit() -> void:
	super.exit()
	
	
	##
	player.WallDetection.enabled = false
	
	
	
	## Alter the height to standing height
	player.HeightAlternator.alter_collider_height(player.standing_height)
	## Reenable headbobbing
	player.headbob_active = true
	
	## We reset the direction, so the Player will stop in place once the slide is over
	player.direction = Vector3.ZERO

## When a movement button is pressed, change to a corresponding State node
func input(event: InputEvent) -> BasePlayerState:
	## Jump from the Slide
	if Input.is_action_just_pressed("input_jump"):
		return jump_state
	## HERE: not necessary?
	## When the Slide button isn't pressed anymore, we return to the idle_state
	elif !Input.is_action_pressed("input_slide"):
		return idle_state
		
	
	return null

## Velocity equasions for this specific state and physics. Unrealated to player Inputs
func physics_process(delta: float) -> BasePlayerState:
	
	## Normalize the direction here since calculate_slide_direction() doesn't do that by itself.
	player.direction = player.direction.normalized()
	
	
	## Decide if the Player going to accelerate or decelerate.
	var temp_accel: float
	## We use the dot product to see if the Player is facing the direction they are moving in
	if player.direction.dot(Vector3(player.direction.x, 0.0, 0.0)) > 0:
		temp_accel = acceleration
	else:
		temp_accel = deceleration
		
	
	
	## Horizontal direction of Player movement based on Input
	## Does the Player want to move left or right while sliding?
	var sideways_input_dir: float = Input.get_axis("input_left", "input_right")
	
	## We want sideways movement to influence Player's velocity in relation to the Camera;
	## Moving left/right moves the Player to left/right from the camera's POV, even allowing the
	## Player to make the slide slower by turning 90° from slide direction and pressing L/R key.
	var sideways_velocity: Vector3 = player.transform.basis * \
		Vector3(sideways_input_dir, 0.0, 0.0).normalized() * \
		player.speed * sideways_speed_multiplier
		
	
	## Apply velocity, take speed_multiplier and acceleration into account
	## and add sideways_velocity.
	## NOTE: Lerping player.velocity itself would also impact vertical (y) velocity,
	## NOTE: so we lerp X and Z separately instead.
	player.velocity.x = lerpf(player.velocity.x, (player.direction.x * player.speed * speed_multiplier) + \
		sideways_velocity.x, acceleration * delta)
	player.velocity.z = lerpf(player.velocity.z, (player.direction.z * player.speed * speed_multiplier) + \
		sideways_velocity.z, acceleration * delta)
	
	
	### We want sideways movement to influence Player's velocity in relation to the Camera;
	### Moving left/right moves the Player to left/right from the camera's POV, even allowing the
	### Player to make the slide slower by turning 90° from slide direction and pressing L/R key.
	#var sideways_velocity: Vector3 = player.transform.basis * \
		#Vector3(sideways_input_dir, 0.0, 0.0).normalized() * player.speed
	#
	### Add that sideways velocity to sliding velocity.
	#player.velocity += sideways_velocity
	
	
	## Apply gravity (which is the Globals' gravity * multiplier)
	## NOTE: Without BulletTime.time_scale, falling is inconsistent when BulletTime is activated
	player.velocity.y -= player.gravity * BulletTime.time_scale * delta
	## Clamp the velocity to be falling_speed_limit at most.
	## NOTE: maxf is used because velocity.y is negative when falling
	player.velocity.y = maxf(player.velocity.y, player.falling_speed_limit)
	
	
	## Even if the Player slides off the floor, they still continue sliding
	#if !player.is_player_on_floor():
		#return fall_state
	
	## If the Player stops moving, return to Idle state. The Y axis is ignored.
	if Vector3(player.velocity.x, 0, player.velocity.z) == Vector3.ZERO:
		return idle_state
		
	
	## We check if the Player is near a wall
	if player.WallDetection.is_colliding():
		print("wall detected")
		## We check if the Player is moving up against the wall
		## If that is so, we stop the slide state.
		if player.is_moving_at_wall(false, 0.7):
			print("MOVED AT WALL AT >0.7")
			return idle_state
			
		
	
	return null


## When the Slide State is first entered, we must check which direction the Player will go in
## If the Player is holding down a directional movement key, then they will slide in that direction.
## Otherwise they slide in the direction they are looking at.
func calculate_slide_direction() -> Vector3:
	## Temporary return vector
	var return_vector: Vector3
	
	## The direction of Player movement based on Input
	var input_dir: Vector2 = Input.get_vector("input_left", "input_right", \
		"input_forwards", "input_backwards")
		
	
	
	## Input takes priority,
	if input_dir:
		## Take Input and use it to determine Player movement in relation to the world.
		## We ignore the Y axis, and place input_dir on the XZ axis
		return_vector = (player.transform.basis * Vector3(input_dir.x, 0.0, input_dir.y).normalized())
		
	## ...but if there is no Input...
	else:
		## Make the Player's direction be the same as their rotation on the Y axis,
		## (which changes with horizontal mouse movement in the Player script)
		## NOTE: I stole this piece of code, I have no idea how it (or the principle behind it) work.
		## I guess sin and cos transform the rotation into the right Vector?
		## NOTE: This Vector is NEGATIVE! This doesn't work otherwise.
		return_vector = -Vector3(sin(player.rotation.y), 0, cos(player.rotation.y))
		
	
	
	## Return the Vector3 we just determined
	return return_vector
