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


@export_group("States")
#
@export var idle_state: BasePlayerState
@export var walk_state: BasePlayerState
@export var jump_state: BasePlayerState
@export var fall_state: BasePlayerState


## This holds the direction in which the Player will slide. Set by calculate_slide_direction()
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
func physics_process(delta) -> BasePlayerState:
	
	## Horizontal direction of Player movement based on Input
	var sideways_input_dir: float = Input.get_axis("input_left", "input_right")
	
	## Reset the direction. Otherwise, sideways movement would accumulate over time.
	player.direction = slide_direction
	## Add sideways movement to the slide
	## (without multipliying by basis, sideways movement would work on global transform)
	player.direction += player.transform.basis.x * sideways_input_dir
	## Normalize the direction, because adding sideways_input_dir can make it go over 1.0
	player.direction = player.direction.normalized()
	
	
	## Decide if the Player going to accelerate or decelerate.
	var temp_accel
	## We use the dot product to see if the Player is facing the direction they are moving in
	if player.direction.dot(Vector3(player.direction.x, 0.0, 0.0)) > 0:
		temp_accel = acceleration
	else:
		temp_accel = deceleration
	
	
	## Apply velocity, take speed_multiplier and acceleration into account
	player.velocity = player.velocity.lerp((player.direction * player.speed * speed_multiplier), \
	acceleration * delta)
	
	
	## Apply gravity (which is the Globals' gravity * multiplier)
	## NOTE: Without BulletTime.time_scale, jumping is inconsistent when BulletTime is activated
	player.velocity.y -= player.gravity * BulletTime.time_scale * delta
	## Clamp the velocity to be falling_speed_limit at most.
	## NOTE: maxf is used because velocity.y is negative when falling
	player.velocity.y = maxf(player.velocity.y, player.falling_speed_limit)
	
	## Even if the Player slides off the floor, they still continue sliding
	#if !player.is_on_floor():
		#return fall_state
	
	## If the Player stops moving, return to Idle state. The Y axis is ignored.
	if Vector3(player.velocity.x, 0, player.velocity.z) == Vector3.ZERO:
		return idle_state
	
	## We check if the Player is near a wall
	if player.WallDetection.is_colliding():
		## We check if the Player is moving up against the wall
		## If that is so, we stop the slide state.
		if player.is_moving_at_wall(false, 0.7):
			return idle_state
	
	return null


## When the Slide State is first entered, we must check in which direction the Player will go
func calculate_slide_direction() -> Vector3:
	## Make the Player's direction be the same as their rotation on the Y axis,
	## (which changes with horizontal mouse movement in the Player script)
	## NOTE: I stole this piece of code, I have no idea how it, and the principle behind it, work.
	## I guess sin and cos transform the rotation into the right Vector?
	## NOTE: This Vector is NEGATIVE! This doesn't work otherwise.
	return -Vector3(sin(player.rotation.y), 0, cos(player.rotation.y))
