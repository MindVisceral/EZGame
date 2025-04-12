extends BasePlayerState

## Stomp causes Camera shaking of this value
@export_range(0.0, 1.0, 0.05) var trauma_amount: float = 0.5


@export_group("States")
#
@export var idle_state: BasePlayerState
@export var walk_state: BasePlayerState
@export var slide_state: BasePlayerState
@export var jump_state: BasePlayerState
@export var walljump_state: BasePlayerState


@export_group("Sounds")
#
@export var stomp_sound: AudioStream


## We store the vertical value of the global position of the Player
## at the time the Stomp state is entered. This is used to make stomp-boosted jumps higher.
var stomp_start_vertical_point: float



func enter() -> void:
	super.enter()
	
	stomp_start_vertical_point = player.global_position.y
	
	player.in_air = true
	## The Player may want to do wall-related movement while in the air
	player.WallDetection.enabled = true
	
	## Reset velocity, otherwise the momentum would persist
	player.velocity = Vector3.ZERO
	## Apply stomp impulse
	player.velocity.y = player.stomp_speed

func exit() -> void:
	super.exit()
	
	## Stomp is done for one reason or another, so we calcualte how far the Player has fallen down
	player.stomp_vertical_distance = abs(stomp_start_vertical_point - player.global_position.y)
	## And we start the StompJumpTimer, it's needed for the jump to work as we want it to.
	player.StompJumpT.start()
	
	print("Start: ", stomp_start_vertical_point)
	print("End: ", player.global_position.y)
	print("DISTANCE: ", player.stomp_vertical_distance)
	
	player.in_air = false
	player.air_time = 0.0
	
	player.WallDetection.enabled = false
	
	## We play the jump sound through the AudioManager autoload
	AudioManager.play(
		AudioManager.Type.POSITIONAL_3D,
		player,
		stomp_sound)

## When a movement button is pressed, change to a corresponding State node
func input(event: InputEvent) -> BasePlayerState:
	## If the Player wants ot jump off the wall...
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
	
	
	## Prepare to walk if a movement key is pressed
	var input_dir: Vector2 = Input.get_vector("input_left", "input_right", \
	 "input_forwards", "input_backwards")
	
	
	## Apply gravity (which is the Globals' gravity * multiplier)
	## NOTE: Might be unnecessary since stomp_speed (and velocity.y) is always const in Stomp state
	player.velocity.y -= player.gravity * BulletTime.time_scale * delta
	## Clamp the velocity to be stomp_speed at most.
	## NOTE: maxf is used because velocity.y is negative when falling. So is stomp_speed.
	player.velocity.y = maxf(player.velocity.y, player.stomp_speed)
	
	
	## Increase air_time - this is used to influence camera shake strength.
	player.air_time += delta
	
	## Check if the Player has reached the ground already
	## Stomp is unstoppable otherwise
	if player.is_player_on_floor():
		
		## Stomp was successful, therefore landing causes Camera shaking;
		## Player's air_time makes the shaking stronger,
		## but it is clamped to always be at least the same as trauma_amount.
		player.air_time = clampf(player.air_time, 1.0, 10.0)
		player.shake_camera(trauma_amount * player.air_time)
		
		## If the jump button has been pressed within the buffer time, jump immediately
		if !player.JumpBufferT.is_stopped():
			return jump_state
		
		## Otherwise (if the Player doesn't take the opportunity to jump)...
		## If a horizontal movement has been detected, return walk_state
		elif input_dir != Vector2.ZERO:
			return walk_state
		else:
			return idle_state
	
	return null
