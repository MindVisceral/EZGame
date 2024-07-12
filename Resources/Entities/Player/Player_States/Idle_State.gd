extends BasePlayerState

@export_group("States")
#
@export var walk_state: BasePlayerState
@export var crouch_state: BasePlayerState
@export var jump_state: BasePlayerState
@export var fall_state: BasePlayerState


func enter() -> void:
	super.enter()

func exit() -> void:
	super.exit()

## When a movement button is pressed, change to a corresponding State node
func input(event: InputEvent) -> BasePlayerState:
	## Detect movement on X and Z axes
	if Input.get_vector("input_left", "input_right", "input_forwards", "input_backwards"):
		return walk_state
	## Crouch
	elif Input.is_action_just_pressed("input_crouch"):
		return crouch_state
	## Jumping
	elif Input.is_action_pressed("input_jump"):
		return jump_state
	
	return null

## Velocity equasions for this specific state and physics. Unrealated to player Inputs
func physics_process(delta) -> BasePlayerState:
	## If the Player is still moving, make them decelerate down to zero
	## Grayed out, seems unneccessary, since Idle only turns on when velocity is ZERO
	#
#	player.velocity.lerp(Vector3(player.velocity.x, 0.0, player.velocity.z), \
#	player.deceleration * delta)
#	print(player.velocity)
	
	## Apply gravity (which is the Globals gravity * multiplier)
	player.velocity.y -= player.gravity
	
	if !player.check_for_floor():
		return fall_state
	
	return null
