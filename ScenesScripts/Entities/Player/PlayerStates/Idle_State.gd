extends BasePlayerState


@export_group("Movement")
#
## Time for the Player to stop in place
@export var deceleration: float = 10.0


@export_group("States")
#
@export var walk_state: BasePlayerState
@export var slide_state: BasePlayerState
@export var crouch_state: BasePlayerState
@export var jump_state: BasePlayerState
@export var fall_state: BasePlayerState


func enter() -> void:
	super.enter()
	
	player.consecutive_walljumps = 0

func exit() -> void:
	super.exit()

## When a movement button is pressed, change to a corresponding State node
func input(event: InputEvent) -> BasePlayerState:
	## Detect movement on X and Z axes
	if Input.get_vector("input_left", "input_right", "input_forwards", "input_backwards"):
		return walk_state
	## Crouch
	elif Input.is_action_just_pressed("input_slide"):
		return slide_state
	## Jumping
	elif Input.is_action_pressed("input_jump"):
		return jump_state
	
	return null

## Velocity equasions for this specific state and physics. Unrelated to player Inputs
func physics_process(delta: float) -> BasePlayerState:
	## If the Player is still moving, make them decelerate down to zero
	## NOTE: Lerping player.velocity itself would also impact vertical (y) velocity,
	## NOTE: so we lerp X and Z separately instead.
	player.velocity.x = lerpf(player.velocity.x, \
		(player.direction.x * player.speed), deceleration * delta)
	player.velocity.z = lerpf(player.velocity.z, \
		(player.direction.z * player.speed), deceleration * delta)
	
	
	## Apply gravity (which is the Globals' gravity * multiplier)
	player.velocity.y -= player.gravity * BulletTime.time_scale * delta
	## Clamp the velocity to be falling_speed_limit at most.
	## NOTE: maxf is used because velocity.y is negative when falling
	player.velocity.y = maxf(player.velocity.y, player.falling_speed_limit)
	
	if !player.is_player_on_floor():
		return fall_state
	
	return null
