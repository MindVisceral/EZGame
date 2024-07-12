extends BasePlayerState

@export_group("States")
#
@export var idle_state: BasePlayerState
@export var walk_state: BasePlayerState
@export var jump_state: BasePlayerState


func enter() -> void:
	super.enter()
	
	player.in_air = true
	
	## Reset velocity, otherwise the momentum would persist
	player.velocity = Vector3.ZERO
	## Apply stomp impulse
	player.velocity.y -= player.stomp_strength

func exit() -> void:
	super.exit()
	
	player.in_air = false

## When a movement button is pressed, change to a corresponding State node
func input(event: InputEvent) -> BasePlayerState:
	
	return null

## Velocity equasions for this specific state and physics. Unrealated to player Inputs
func physics_process(delta) -> BasePlayerState:
	
	## Prepare to walk if a movement key is pressed
	var input_dir: Vector2 = Input.get_vector("input_left", "input_right", \
	 "input_forwards", "input_backwards")
	
	## Prepare the jump input buffer
	## just_pressed makes this Input require timing, but _pressed, well, can just be pressed down
	if Input.is_action_just_pressed("input_jump"):
		player.JumpBufferT.start()
	
	
	## Apply gravity (which is the Globals gravity * multiplier)
	player.velocity.y -= player.gravity * BulletTime.time_scale
	
	
	## Check if the Player has reached the ground already
	## Stomp is unstoppable otherwise
	if player.check_for_floor():
		
		## If the jump button has been pressed within the buffer time, allow for an immediate jump
		if !player.JumpBufferT.is_stopped():
			return jump_state
		
		## Otherwise...
		## If a horizontal movement has been detected, return walk_state
		elif input_dir != Vector2.ZERO:
			return walk_state
		else:
			return idle_state
	
	return null
