extends BasePlayerState

@export_group("Movement")
#
## Time for the character to reach full speed
@export var acceleration: float = 8
## Time for the character to stop in place
@export var deceleration: float = 10
## If this is true, speed_multiplier from the previous state will be use instead of the default one
@export var use_previous_state_speed_multiplier: bool = true
## Speed to be multiplied when active the ability
@export var default_speed_multiplier: float = 1.2

## Current speed multiplier, carried over from the previous state
## If it doesn't exist in the previous state, default_speed_multiplier will be used
var speed_multiplier: float ## Not needed, no other state has a higher multipier anyway


@export_group("States")
#
@export var idle_state: BasePlayerState
@export var walk_state: BasePlayerState
@export var crouch_state: BasePlayerState
@export var jump_state: BasePlayerState
@export var stomp_state: BasePlayerState
@export var wallrun_state: BasePlayerState
@export var walljump_state: BasePlayerState

## Timer, so that the ground isn't detected immediately after a jump
## Check Editor description for an explanation
@onready var ground_timer: Timer = $GroundTimer

func enter() -> void:
	super.enter()
	
	player.in_air = true
	## The Player may want to do wall-related movement while in the air
	player.WallDetection.enabled = true
	
	## Check how fast we should go
	speed_multiplier_check()
	
	## Start the timer
	ground_timer.start()
	
	## Apply jump impulse
	player.velocity.y += player.jump_height * player.jump_height_multiplier
	## Reset jump_height_multiplier
	player.jump_height_multiplier = 1.0

func exit() -> void:
	super.exit()
	
	player.in_air = false
	player.air_time = 0.0
	
	player.WallDetection.enabled = false
	
	## Reset ground timer
	ground_timer.stop()

## When a movement button is pressed, change to a corresponding State node
func input(event: InputEvent) -> BasePlayerState:
	## If the Player wants to stomp back to the ground...
	if Input.is_action_just_pressed("input_crouch"):
		return stomp_state
	## If the Player wants to jump off the wall...
	## NOTE: This has to be frame-perfect, because the wallrun_state is likely to trigger first
	if Input.is_action_just_pressed("input_jump"):
		if player.WallDetection.is_colliding():
			return walljump_state
	
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
			(player.direction.x * player.speed * speed_multiplier), \
			temp_accel * delta)
		player.velocity.z = lerp(player.velocity.z, \
			(player.direction.z * player.speed * speed_multiplier), \
			temp_accel * delta)
		
	
#	player.velocity = Vector3(player.velocity.x, 0, player.velocity.z).lerp((player.direction \
#		* player.speed * speed_multiplier), temp_accel * delta)
	
#	player.velocity.x += player.velocity.x + (player.direction.x * player.speed * speed_multiplier)
#	player.velocity.z += player.velocity.z + (player.direction.z * player.speed * speed_multiplier)
	
	
	## Apply gravity (which is the Globals' gravity * multiplier)
	## No multipier used for now.
	## NOTE: Without BulletTime.time_scale, jumping is inconsistent when BulletTime is activated
	player.velocity.y -= player.gravity * BulletTime.time_scale * delta \
						+ (player.gravity * player.air_time)
	
	## air_time multiplier is only applied when the Player is falling from the jump's peak
	if player.velocity.y <= 0:
		## Increase air_time, thus increasing gravity until the ground is reached.
		player.air_time += delta * player.air_time_multiplier
	
	
	## A short time after the Raycast leaves the ground...
	if ground_timer.is_stopped():
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
			
			## We check if the Player is moving up against the wall
			if player.is_moving_at_wall():
			
				## The Player is near a wall, but are they falling?
				if player.velocity.y <= 0:
					## Since the Player is near a wall and is falling, we can make them run along it.
					## NOTE: WallJumping is detected on Input instead! This is only for WallRunning.
					return wallrun_state
				
			
		
	
	return null


## HERE - unnecessary, there is no state that has a higher multiplier than Jump
## Check if this state should use the previous state's speed_multiplier
func speed_multiplier_check() -> void:
	## Set the multiplier to the default...
	self.speed_multiplier = self.default_speed_multiplier
	
	## If we want the state_multiplier to change...
	if use_previous_state_speed_multiplier == true:
		## If the previous state has a speed_multiplier variable...
		if previous_state.get("speed_multiplier") != null:
			## If that variable is higher than the default...
			if previous_state.speed_multiplier >= self.default_speed_multiplier:
				self.speed_multiplier = previous_state.speed_multiplier
