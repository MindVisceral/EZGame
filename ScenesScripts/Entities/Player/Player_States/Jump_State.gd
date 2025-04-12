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


## Timer, so that the ground isn't detected immediately after a jump
## Check Editor description for an explanation
@onready var ground_timer: Timer = $GroundTimer


## Stomp-boosted jump flag;
## If the jump is performed within StompJumpTimer time, the jump makes the Player go
## up by the distance between the stomp's start and end positions.
var stomp_boosted: bool = false
## The distance remaining for the Player to travel before the boost is over and gravity kicks in
var remaining_boost_distance: float = 0.0

var boost_distance: float = 0.0


func enter() -> void:
	super.enter()
	
	player.in_air = true
	## The Player may want to do wall-related movement while in the air
	player.WallDetection.enabled = true
	
	## Start the timer
	ground_timer.start()
	
	## Apply jump impulse; Either the Player jumps up by jump_height,
	## or they go up by stomp_vertical_distance - IF this jump happens within a time after a Stomp
	player.velocity.y += apply_jump_impulse()
	
	## We play the jump sound through the AudioManager autoload
	AudioManager.play(
		AudioManager.Type.NON_POSITIONAL,
		player,
		jump_sound)
		
	

func exit() -> void:
	super.exit()
	
	
	
	boost_distance = 0.0
	
	
	## Reset!
	stomp_boosted = false
	remaining_boost_distance = 0.0
	#
	player.in_air = false
	#
	player.WallDetection.enabled = false
	
	## Reset ground timer
	ground_timer.stop()
	

## When a movement button is pressed, change to a corresponding State node
func input(event: InputEvent) -> BasePlayerState:
	## If the Player wants to stomp back to the ground...
	if Input.is_action_just_pressed("input_slide"):
		return stomp_state
		
	## If the Player wants to jump off the wall...
	if Input.is_action_just_pressed("input_jump"):
		if player.WallDetection.is_colliding():
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
		
	
	## When the horizontal Input keys are pressed, make the Player move in that direction
	## Otherwise, keep the momentum
	if player.direction.x != 0 and player.direction.z != 0:
		player.velocity.x = lerp(player.velocity.x, \
			(player.direction.x * player.speed * speed_multiplier), temp_accel * delta)
		player.velocity.z = lerp(player.velocity.z, \
			(player.direction.z * player.speed * speed_multiplier), temp_accel * delta)
		
	
	
#	player.velocity = Vector3(player.velocity.x, 0, player.velocity.z).lerp((player.direction \
#		* player.speed * speed_multiplier), temp_accel * delta)
	
#	player.velocity.x += player.velocity.x + (player.direction.x * player.speed * speed_multiplier)
#	player.velocity.z += player.velocity.z + (player.direction.z * player.speed * speed_multiplier)
	
	
	
	### According to apply_jump_impulse, this is a stomp-boosted jump!
	#if (stomp_boosted == true) and \
	### This is a timer of sorts - remaining_boost_distance will tick down until it's '< 0'.
	### In essence, the Player will go up until they reach the distance
	### between the stomp's start and end positions
	#(remaining_boost_distance > 0.0):
		
		
	if (stomp_boosted == true):
		if ((remaining_boost_distance / boost_distance) > 0.5):
			
			## Make the Player go up
			player.velocity.y += (player.gravity * (1.0 - (remaining_boost_distance / boost_distance))) * \
				BulletTime.time_scale * delta
			## Clamp the velocity to be jump_speed_limit at most
			#player.velocity.y = minf(player.velocity.y, player.jump_speed_limit)
			
			## This is the actual timer part.
			## It determines when the Player has finished travelling the stomp-boosted distance
			remaining_boost_distance -= player.velocity.y * BulletTime.time_scale * delta
		else:
			player.velocity.y -= player.gravity * BulletTime.time_scale * delta
			player.velocity.y = maxf(player.velocity.y, player.falling_speed_limit)
	
	
	
	
	
	## The Player has either gone the distance or this never was a stomp-boosted jump to begin with
	## Either way, we apply gravity once again.
	else:
		## Apply gravity (which is the Globals' gravity * multiplier)
		## No multipier used for now.
		## NOTE: Without BulletTime.time_scale, jumping is inconsistent when BulletTime is activated
		player.velocity.y -= player.gravity * BulletTime.time_scale * delta
		## Clamp the velocity to be falling_speed_limit at most.
		## NOTE: maxf is used because velocity.y is negative when falling
		player.velocity.y = maxf(player.velocity.y, player.falling_speed_limit)
		
	
	## A short time after the Raycast leaves the ground...
	if ground_timer.is_stopped():
		## Check if the Player is on floor...
		if player.is_player_on_floor():
			
			## If the jump button has been pressed within the buffer time, jump immediately
			if !player.JumpBufferT.is_stopped():
				return jump_state
			
			## Otherwise (if the Player doesn't take the opportunity to jump)...
			#
			## If the Player stops moving around, return to Idle state. The Y axis is ignored
			elif Vector3(player.velocity.x, 0, player.velocity.z) == Vector3.ZERO:
				player.play_landing_sound(landing_sound)
				return idle_state
			## Otherwise, keep on walking
			else:
				player.play_landing_sound(landing_sound)
				return walk_state
			
		
		
		## The Player isn't on the floor, so we check if they're near a wall maybe...
		elif player.WallDetection.is_colliding():
			## We check if the Player is moving up against the wall
			if player.is_moving_at_wall(true):
				## The Player is near a wall, but are they falling?
				if player.velocity.y <= 0:
					## Since the Player is near a wall and is falling, we can make them run along it.
					## NOTE: WallJumping is detected on Input instead! This is only for WallRunning.
					return wallrun_state
				
			
		
	
	return null


## Calculates this jump's height
func apply_jump_impulse() -> float:
	
	var impulse_jump_height: float = 0.0
	
	## If a Stomp has just been finished, this is a Stomp-boosted jump,
	## so we will 
	if !player.StompJumpT.is_stopped():
		
		## This jump will be stomp-boosted!
		stomp_boosted = true
		## Sometimes the Player seems to move during a Stomp-boosted jump without Input, so...
		player.velocity.x = 0.0
		player.velocity.z = 0.0
		
		## We will need the distance between the stomp's start and end points.
		## NOTE: The jump will be limited to stomp_jump_height_limit value at most!
		boost_distance = minf(player.stomp_vertical_distance, player.stomp_jump_height_limit)
		remaining_boost_distance = boost_distance
		
		## The jump impulse should be either the size of the boost, or the regular jump height,
		## whichever is bigger.
		impulse_jump_height = maxf(boost_distance, player.jump_height)
		
		
	
	## Otherwise, we just do a regular jump
	else:
		impulse_jump_height += player.jump_height
		
	
	## Either way, we must reset the stomp_vertical_distance
	player.stomp_vertical_distance = 0.0
	
	return impulse_jump_height
