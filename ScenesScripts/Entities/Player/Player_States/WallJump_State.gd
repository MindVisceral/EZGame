extends BasePlayerState

@export_group("Movement")
#
## Time for the Player to reach full speed
@export var acceleration: float = 8.0
## Time for the Player to stop in place
@export var deceleration: float = 8.0
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
@export var jump_sound: AudioStream
@export var landing_sound: AudioStream


## Timer, so that the wall isn't detected immediately after a jump
## Check Editor description for an explanation
@onready var wall_timer: Timer = $WallTimer

func enter() -> void:
	super.enter()
	
	player.in_air = true
	player.consecutive_walljumps += 1
	## The Player may want to do wall-related movement while in the air
	player.WallDetection.enabled = true
	
	## Start the timer
	wall_timer.start()
	
	## Player vertical velocity is reset, because if it wasn't, gravity and other calculations from
	## the previous state would mess with the jump, making it inconsistent
	player.velocity.y = 0.0
	
	## Calculate and apply jump impulse (depending on the wall's normal)
	player.velocity += wall_normal_check()
	
	## We play the jump sound through the AudioManager autoload
	## NOTE: pitch_scale is divided by the number of consecutive walljumps
	AudioManager.play(
		AudioManager.Type.NON_POSITIONAL,
		player,
		jump_sound,
		0.0,
		1.0 / player.consecutive_walljumps)

func exit() -> void:
	super.exit()
	
	player.in_air = false
	
	player.WallDetection.enabled = false
	
	## Reset ground timer
	wall_timer.stop()


## When a movement button is pressed, change to a corresponding State node
func input(event: InputEvent) -> BasePlayerState:
	## If the Player wants to stomp back to the ground...
	if Input.is_action_just_pressed("input_slide"):
		return stomp_state
	## If the Player wants to walljump again...
	if Input.is_action_just_pressed("input_jump"):
		return walljump_state
	
	return null

## Velocity equasions for this specific state and physics. Unrealated to player Inputs
func physics_process(delta: float) -> BasePlayerState:
	
	## Prepare the jump input buffer
	## just_pressed makes this Input require timing, but _pressed allows for hopping
	if Input.is_action_just_pressed("input_jump"):
		player.JumpBufferT.start()
	
	
	## The direction the Player's movement based on Input
	var input_dir: Vector2 = Input.get_vector("input_left", "input_right", \
	 "input_forwards", "input_backwards")
	## We ignore the Y axis, and place input_dir on the XZ axis
	player.direction = (player.transform.basis * \
		Vector3(input_dir.x, 0.0, input_dir.y).normalized())
		
	
	## Decide if the Player going to accelerate or decelerate.
	var temp_accel: float
	## We use the dot product to see if the Player is facing the direction they are moving in
	if player.direction.dot(Vector3(player.direction.x, 0.0, 0.0)) > 0:
		temp_accel = acceleration
	else:
		temp_accel = deceleration
	
	## Control in the air is damped (or raised) while moving (horizontally)
	temp_accel *= player.air_control
	
	### Apply velocity, take speed_multiplier and acceleration into account
	### NOTE: Lerping player.velocity itself would also impact vertical (y) velocity,
	### NOTE: so we lerp X and Z separately instead.
	#player.velocity.x = lerpf(player.velocity.x, \
		#(player.direction.x * player.speed * speed_multiplier), temp_accel * delta)
	#player.velocity.z = lerpf(player.velocity.z, \
		#(player.direction.z * player.speed * speed_multiplier), temp_accel * delta)
	
	## When the horizontal Input keys are pressed, make the Player move in that direction
	## Otherwise, keep the momentum
	if player.direction.x != 0 and player.direction.z != 0:
		player.velocity.x = lerp(player.velocity.x, \
			(player.direction.x * player.speed * speed_multiplier), temp_accel * delta)
		player.velocity.z = lerp(player.velocity.z, \
			(player.direction.z * player.speed * speed_multiplier), temp_accel * delta)
		
	
	## Apply gravity (which is the Globals' gravity * multiplier)
	## NOTE: Without BulletTime.time_scale, jumping is inconsistent when BulletTime is activated
	player.velocity.y -= player.gravity * BulletTime.time_scale * delta
	## Clamp the velocity to be falling_speed_limit at most.
	## NOTE: maxf is used because velocity.y is negative when falling
	player.velocity.y = maxf(player.velocity.y, player.falling_speed_limit)
	
	## A short time after the Shapecast leaves the wall...
	if wall_timer.is_stopped():
		## Check if the Player is on floor...
		if player.is_player_on_floor():
			
			## If the jump button has been pressed within the buffer time, allow for another jump
			if !player.JumpBufferT.is_stopped():
				print("        REGULAR JUMP FROM WALLJUMP")
				return jump_state
			
			## Otherwise (if the Player doesn't take the opportunity to jump)...
			## If the Player stops moving around, return to Idle state. The Y axis is ignored
			elif Vector3(player.velocity.x, 0, player.velocity.z) == Vector3.ZERO:
				player.play_landing_sound(landing_sound)
				return idle_state
			## Otherwise, keep on walking
			else:
				player.play_landing_sound(landing_sound)
				return walk_state
			
		## The Player isn't on the floor, so we check if they're near a wall...
		elif player.WallDetection.is_colliding():
			## We check if the Player is moving up against the wall
			if player.is_moving_at_wall(true):
				## The Player is near a wall, but are they falling?
				if player.velocity.y <= 0:
					## Since the Player is near a wall and is falling, we can make them run along it.
					## NOTE: WallJumping is detected on Input instead! This is only for WallRunning.
					return wallrun_state
			
		
	
	
	return null

## We want the Player to jump away from a wall.
## We use the wall's normal to calculate which way the Player should be pushed.
func wall_normal_check() -> Vector3:
	## The direction in which the Player will jump away from the wall
	var jump_velocity: Vector3 = Vector3.ZERO
	
	## Get the nearest wall's nearest face's normal
	var wall_normal_result: Vector3 = player.find_closest_wall_normal()
	
	## Horizontal velocity calculations;
	## Multiplying is fine here, because the normal is always either 0 or 1
	jump_velocity.x = wall_normal_result.x * player.wall_jump_distance
	jump_velocity.z = wall_normal_result.z * player.wall_jump_distance
	
	## Vertical impulse;
	## We must add the height value and not multiply it
	jump_velocity.y += player.wall_jump_height
	
	## Return the jump direction away from the normal of the nearest wall
	return jump_velocity
