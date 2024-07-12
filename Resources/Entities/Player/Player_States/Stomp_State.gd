extends BasePlayerState

@export_group("States")
#
@export var idle_state: BasePlayerState
@export var walk_state: BasePlayerState
@export var jump_state: BasePlayerState


func enter() -> void:
	## Reset velocity, otherwise the momentum would persist
	player.velocity = Vector3.ZERO
	## Apply stomp impulse
	player.velocity.y -= player.stomp_strength
	
	super.enter()

func exit() -> void:
	super.exit()

## When a movement button is pressed, change to a corresponding State node
func input(event: InputEvent) -> BasePlayerState:
	
	return null

## Velocity equasions for this specific state and physics. Unrealated to player Inputs
func physics_process(delta) -> BasePlayerState:
	
	## Prepare the jump input buffer
	## just_pressed makes this Input require timing, but _pressed, well, can just be pressed down
	if Input.is_action_just_pressed("input_jump"):
		player.JumpBufferT.start()
	
	
	## Apply gravity (which is the Globals gravity * multiplier)
	player.velocity.y -= player.gravity
	
	
	## Check if the Player has reached the ground already
	if player.check_for_floor():
		
		## If the jump button has been pressed within the buffer time, allow for an immediate jump
		if !player.JumpBufferT.is_stopped():
			return jump_state
		else:
			return idle_state
	
	return null
