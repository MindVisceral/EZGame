extends BasePlayerState

## Stomp causes Camera shaking of this value
@export_range(0.0, 1.0, 0.05) var trauma_amount: float = 0.5


@export_group("States")
#
@export var idle_state: BasePlayerState
@export var walk_state: BasePlayerState
@export var jump_state: BasePlayerState
@export var walljump_state: BasePlayerState


func enter() -> void:
	super.enter()
	
	player.in_air = true
	## The Player may want to do wall-related movement while in the air
	player.WallDetection.enabled = true
	
	## Reset velocity, otherwise the momentum would persist
	player.velocity = Vector3.ZERO
	## Apply stomp impulse
	player.velocity.y -= player.stomp_strength * player.gravity * BulletTime.time_scale

func exit() -> void:
	super.exit()
	
	player.in_air = false
	player.air_time = 0.0
	
	player.WallDetection.enabled = false

## When a movement button is pressed, change to a corresponding State node
func input(event: InputEvent) -> BasePlayerState:
	## If the Player wants ot jump off the wall...
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
	
	
	## Prepare to walk if a movement key is pressed
	var input_dir: Vector2 = Input.get_vector("input_left", "input_right", \
	 "input_forwards", "input_backwards")
	
	
	## Apply gravity (which is the Globals' gravity * multiplier)
	player.velocity.y -= player.gravity * BulletTime.time_scale * delta
	
	## Increase air_time - this is used to influence camera shake strength.
	## NOTE: Notice that player.air_time_multiplier isn't used here - we want actual time in air
	player.air_time += delta
	
	## Check if the Player has reached the ground already
	## Stomp is unstoppable otherwise
	if player.check_for_floor() or player.is_on_floor():
		
		## Stomp was successful, therefore landing causes Camera shaking;
		## Player's air time makes the shaking stronger,
		## but it is clamped to always be at the minimum of trauma_amount.
		player.air_time = clampf(player.air_time, 1.0, 10.0)
		player.PlayerCamera.add_trauma(trauma_amount * player.air_time)
		
		## If the jump button has been pressed within the buffer time, jump immediately
		if !player.JumpBufferT.is_stopped():
			
			## HERE: This requires very precise Inputs; It should account for a few milisecond
			## HERE: after touching the ground too.
			## The jump_height_multiplier is only applied to the very next jump
			player.jump_height_multiplier = 1.0 + abs(player.velocity.y) + player.air_time
			
			return jump_state
		
		## Otherwise (if the Player doesn't take the opportunity to jump)...
		## If a horizontal movement has been detected, return walk_state
		elif input_dir != Vector2.ZERO:
			return walk_state
		else:
			return idle_state
	
	return null
