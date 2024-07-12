extends BasePlayerState

@export_group("Movement")
#
## Time for the character to reach full speed
@export var acceleration: float = 8
## Time for the character to stop walking
@export var deceleration: float = 10
## Speed to be multiplied when active the ability
@export var speed_multiplier: float = 1


@export_group("States")
#
@export var idle_state: BasePlayerState
@export var walk_state: BasePlayerState
@export var jump_state: BasePlayerState
@export var stomp_state: BasePlayerState
@export var wallrun_state: BasePlayerState

## Timer, so that the wall isn't detected immediately after a jump
## Check Editor description for an explanation
@onready var wall_timer: Timer = $WallTimer

func enter() -> void:
	super.enter()
	
	player.in_air = true
	## The Player may want to do wall-related movement while in the air
	player.WallDetection.enabled = true
	
	## Start the timer
	wall_timer.start()
	
	## Calculate and apply jump impulse (depending on the wall's normal)
	player.velocity += wall_normal_check()

func exit() -> void:
	super.exit()
	
	player.in_air = false
	player.air_time = 0.0
	
	player.WallDetection.enabled = false
	
	## Reset ground timer
	wall_timer.stop()


## When a movement button is pressed, change to a corresponding State node
func input(event: InputEvent) -> BasePlayerState:
	## If the Player wants to stomp back to the ground...
	if Input.is_action_just_pressed("input_crouch"):
		return stomp_state
	
	return null

## Velocity equasions for this specific state and physics. Unrealated to player Inputs
func physics_process(delta) -> BasePlayerState:
	
	## Prepare the jump input buffer
	## just_pressed makes this Input require timing, but _pressed allows for hopping
	if Input.is_action_just_pressed("input_jump"):
		player.JumpBufferT.start()
	
	
	## The direction the Player's movement based on Input
	var input_dir: Vector2 = Input.get_vector("input_left", "input_right", \
	 "input_forwards", "input_backwards")
	## We keep the Y axis the same, and place input_dir on the XZ axis
	player.direction = (player.transform.basis * \
		Vector3(input_dir.x, 0.0, input_dir.y).normalized())
		
	
	## Decide if the Player going to accelerate or decelerate.
	var temp_accel
	## We use the dot product to see if the Player is facing the direction they are moving in
	if player.direction.dot(Vector3(player.direction.x, 0.0, 0.0)) > 0:
		temp_accel = acceleration
	else:
		temp_accel = deceleration
	
	## Control in the air is damped (or raised) while moving (horizontally)
#	temp_accel *= player.air_control
	
	## Apply velocity, take speed_multiplier and acceleration into account
	## But only on X and Z axes! The Y axis should be unrestrained by .speed and .multipliers
	#player.velocity.x = lerp(player.velocity.x, \
		#(player.direction.x * player.speed * speed_multiplier), \
		#temp_accel * delta)
	#player.velocity.z = lerp(player.velocity.z, \
		#(player.direction.z * player.speed * speed_multiplier), \
		#temp_accel * delta)
	
	## When the horizontal Input keys are pressed, make the Player move in that direction
	## Otherwise, keep the momentum
	if player.direction.x != 0 and player.direction.z != 0:
		player.velocity.x = lerp(player.velocity.x, \
			(player.direction.x * player.speed * speed_multiplier)  \
			* (player.walljump_input_contribution), \
			temp_accel * delta)
		player.velocity.z = lerp(player.velocity.z, \
			(player.direction.z * player.speed * speed_multiplier)  \
			* (player.walljump_input_contribution), \
			temp_accel * delta)
		
	
	## Apply gravity (which is the Globals' gravity * multiplier)
	## NOTE: Without BulletTime.time_scale, jumping is inconsistent when BulletTime is activated
	player.velocity.y -= player.gravity * BulletTime.time_scale * delta \
						+ (player.gravity * player.air_time)
	
	## Increase air_time, thus increasing gravity until the ground is reached.
	player.air_time += delta * player.air_time_multiplier
	
	
	## A short time after the Shapecast leaves the wall...
	if wall_timer.is_stopped():
		## Check if the Player is on floor...
		if player.check_for_floor():
			
			## If the jump button has been pressed within the buffer time, allow for another jump
			if !player.JumpBufferT.is_stopped():
				return jump_state
			
			## Otherwise (if the Player doesn't take the opportunity to jump)...
			## If the Player stops moving around, return to Idle state. The Y axis is ignored
			elif Vector3(player.velocity.x, 0, player.velocity.z) == Vector3.ZERO:
				return idle_state
			## Otherwise, keep on walking
			else:
				return walk_state
			
		## The Player isn't on the floor, so we check if they're near a wall...
		elif player.WallDetection.is_colliding():
			## The Player is near a wall, so we make them run on it.
			return wallrun_state
			
		
	
	
	return null

## We want the Player to jump away from a wall.
## We use the wall's normal to calculate which way the Player should be pushed.
func wall_normal_check() -> Vector3:
	## The direction in which the Player will jump away from the wall
	var jump_direction: Vector3 = Vector3.ZERO
	
	var wall_normal_result: Vector3 = player.find_closest_wall_normal()
	
	## Horizontal calculations;
	## Multiplying is fine here, because the normal is always either 0 or 1
	jump_direction.x = wall_normal_result.x * player.wall_jump_distance
	jump_direction.z = wall_normal_result.z * player.wall_jump_distance
	
	## Vertical impulse;
	## We must add the height value and not multiply it
	jump_direction.y += player.wall_jump_height
	
	## Return the jump direction away from the normal of the nearest wall
	return jump_direction
