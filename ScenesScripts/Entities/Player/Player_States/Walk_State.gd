extends BasePlayerState

@export_group("Movement")
#
## Time for the Player to reach full speed
@export var acceleration: float = 8.0
## Time for the Player to stop in place
@export var deceleration: float = 10.0
## Speed while in this state
@export_range(0.1, 2.0, 0.05) var speed_multiplier: float = 1.0


@export_group("States")
#
@export var idle_state: BasePlayerState
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
	## Crouch
	if Input.is_action_just_pressed("input_slide"):
		return slide_state
	## Jump
	elif Input.is_action_just_pressed("input_jump"):
		return jump_state
	
	return null

## Velocity equasions for this specific state and physics. Unrealated to player Inputs
func physics_process(delta: float) -> BasePlayerState:
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
	
	## Apply velocity, take speed_multiplier and acceleration into account
	## NOTE: Lerping player.velocity itself would also impact vertical (y) velocity,
	## NOTE: so we lerp X and Z separately instead.
	player.velocity.x = lerpf(player.velocity.x, \
		(player.direction.x * player.speed * speed_multiplier), temp_accel * delta)
	player.velocity.z = lerpf(player.velocity.z, \
		(player.direction.z * player.speed * speed_multiplier), temp_accel * delta)
	
	## Apply gravity (which is the Globals' gravity * multiplier)
	player.velocity.y -= player.gravity * BulletTime.time_scale * delta
	## Clamp the velocity to be falling_speed_limit at most.
	## NOTE: maxf is used because velocity.y is negative when falling
	player.velocity.y = maxf(player.velocity.y, player.falling_speed_limit)
	
	if !player.is_player_on_floor():
		return fall_state
	
	## If the Player stops moving, return to Idle state. The Y axis is ignored
	if Vector3(player.velocity.x, 0.0, player.velocity.z) == Vector3.ZERO:
		return idle_state
	
	return null
