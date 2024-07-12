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

## Timer, so that the ground isn't detected immediately after a jump
## Check Editor description for an explanation
@onready var ground_timer: Timer = $GroundTimer

func enter() -> void:
	super.enter()
	
	player.in_air = true
	
	## Check how fast we should go
	speed_multiplier_check()
	
	## Start the timer
	ground_timer.start()
	
	## Apply jump impulse
	player.velocity.y += player.jump_height

func exit() -> void:
	super.exit()
	
	player.in_air = false
	
	## Reset ground timer
	ground_timer.stop()

## When a movement button is pressed, change to a corresponding State node
func input(event: InputEvent) -> BasePlayerState:
	if Input.is_action_just_pressed("input_crouch"):
		return stomp_state
	
	return null

## Velocity equasions for this specific state and physics. Unrealated to player Inputs
func physics_process(delta) -> BasePlayerState:
	
	## Prepare the jump input buffer
	## just_pressed makes this Input require timing, but _pressed allows for hopping
	if Input.is_action_just_pressed("input_jump"):
		player.JumpBufferT.start()
	
	
	## The direction of Player movement based on Input
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
	
	## Control in the air is damped (or raised) while moving horizontally
#	temp_accel *= player.air_control
	
	## Apply velocity, take speed_multiplier and acceleration into account
	## But only on X and Z axes! The Y axis should be unrestrained by .speed and .multipliers
#	player.velocity.x = lerp(player.velocity.x, \
#		(player.direction.x * player.speed * speed_multiplier), \
#		temp_accel * delta)
#	player.velocity.z = lerp(player.velocity.z, \
#		(player.direction.z * player.speed * speed_multiplier), \
#		temp_accel * delta)
	
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
	
	
	## Apply gravity (which is the Globals gravity * multiplier)
	player.velocity.y -= player.gravity
	
	
	## A short time after the Raycast leaves the ground...
	if ground_timer.is_stopped():
		## Check if the Player is on floor
		if player.check_for_floor():
			
			## If the jump button has been pressed within the buffer time, allow for another jump
			if !player.JumpBufferT.is_stopped():
				return jump_state
			
			## Otherwise...
			## If the Player stops moving around, return to Idle state. The Y axis is ignored
			elif Vector3(player.velocity.x, 0, player.velocity.z) == Vector3.ZERO:
				return idle_state
			## Otherwise, keep on walking
			else:
				return walk_state
	
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
