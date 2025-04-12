extends BasePlayerState

@export_group("Movement")
#
## Time for the Player to reach full speed
@export var acceleration: float = 8.0
## Time for the Player to stop in place
@export var deceleration: float = 10.0
## Speed while in this state
@export_range(0.1, 2.0, 0.05) var speed_multiplier: float = 1.2


@export_group("States")
#
@export var idle_state: BasePlayerState
@export var walk_state: BasePlayerState
@export var slide_state: BasePlayerState
@export var jump_state: BasePlayerState
@export var stomp_state: BasePlayerState
@export var wallrun_state: BasePlayerState
@export var walljump_state: BasePlayerState


@export_group("Sounds")
#
@export var landing_sound: AudioStream


func enter() -> void:
	super.enter()
	
	
	player.in_air = true
	
	## The Player is falling now, but if they press the jump button before this Timer runs out,
	## they will jump, despite not being grounded. This is coyote time and it's a gamefeel feature.
	player.CoyoteTimeT.start()
	
	## The Player may want to do wall-related movement while in the air
	player.WallDetection.enabled = true
	

func exit() -> void:
	super.exit()
	
	player.in_air = false
	
	player.WallDetection.enabled = false
	

## When a movement button is pressed, change to a corresponding State node
func input(event: InputEvent) -> BasePlayerState:
	if Input.is_action_just_pressed("input_slide"):
		return stomp_state
	## If the Player wants to jump...
	if Input.is_action_just_pressed("input_jump"):
		## CoyoteTime takes priority; the Player will perform a regular jump
		if !player.CoyoteTimeT.is_stopped():
			return jump_state
		## Otherwise, if coyote time doesn't apply, try to jump off the nearest wall
		if player.WallDetection.is_colliding():
			return walljump_state
		
	
	return null



## Velocity equasions for this specific state and physics. Unrealated to player Inputs
func physics_process(delta: float) -> BasePlayerState:
	
	## Prepare the jump input buffer
	## just_pressed makes this Input require timing, but _pressed allows for hopping
	if Input.is_action_just_pressed("input_jump"):
		player.JumpBufferT.start()
		
	
	## The direction of Player movement based on Input
	var input_dir: Vector2 = Input.get_vector("input_left", "input_right", \
		"input_forwards", "input_backwards")
	## We ignore the Y axis, and place input_dir on the XZ axis
	player.direction = (player.transform.basis * Vector3(input_dir.x, 0.0, input_dir.y).normalized())
	
	
	## Decide if the Player going to accelerate or decelerate.
	var temp_accel: float
	## We use the dot product to see if the Player is facing the direction they are moving in
	if player.direction.dot(Vector3(player.direction.x, 0.0, 0.0)) > 0:
		temp_accel = acceleration
	else:
		temp_accel = deceleration
		
	
	
	## When the horizontal Input keys are pressed, make the Player move in that direction
	## Otherwise, keep the momentum
	if player.direction.x != 0 and player.direction.z != 0:
		player.velocity.x = lerp(player.velocity.x, \
			(player.direction.x * player.speed * speed_multiplier), temp_accel * delta)
		player.velocity.z = lerp(player.velocity.z, \
			(player.direction.z * player.speed * speed_multiplier), temp_accel * delta)
		
	
	
	## Apply gravity (which is the Globals' gravity * multiplier)
	## NOTE: Without BulletTime.time_scale, falling is inconsistent when BulletTime is activated
	player.velocity.y -= player.gravity * BulletTime.time_scale * delta
	## Clamp the velocity to be falling_speed_limit at most.
	## NOTE: maxf is used because velocity.y is negative when falling
	player.velocity.y = maxf(player.velocity.y, player.falling_speed_limit)
	
	
	## Check if the Player has reached the ground already
	if player.is_player_on_floor():
		
		## If the jump button has been pressed within the buffer time, allow for another jump
		if !player.JumpBufferT.is_stopped():
			return jump_state
			
		
		## Otherwise (if the Player doesn't take the opportunity to jump)...
		## If the Player stops moving around, return to Idle state. The Y axis is ignored
		elif Vector3(player.velocity.x, 0, player.velocity.z) == Vector3.ZERO:
			player.play_landing_sound(landing_sound)
			return idle_state
		## Otherwise, get to walking
		else:
			player.play_landing_sound(landing_sound)
			return walk_state
			
		
	## The Player isn't on the floor, so we check if they're near a wall...
	elif player.WallDetection.is_colliding() and player.is_moving_at_wall(true):
		## The Player is near a wall, so we make them run on it.
		## NOTE: WallJumping is detected on Input instead! This is only for WallRunning.
		return wallrun_state
		
	
	
	return null
