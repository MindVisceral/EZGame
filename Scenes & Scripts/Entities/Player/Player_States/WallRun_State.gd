extends BasePlayerState

@export_group("Movement")

## Time for the character to reach full speed
@export var acceleration: float = 8
## Time for the character to stop walking
@export var deceleration: float = 10
## Speed to be multiplied when active the ability
@export var speed_multiplier: float = 1


@export_group("States")
#
@export var idle_state: BasePlayerState
@export var walk_state: BasePlayerState
@export var jump_state: BasePlayerState
@export var fall_state: BasePlayerState
@export var stomp_state: BasePlayerState
@export var walljump_state: BasePlayerState


func enter() -> void:
	super.enter()
	
	player.WallDetection.enabled = true
	player.on_wall = true

func exit() -> void:
	super.exit()
	
	player.WallDetection.enabled = false
	player.on_wall = false


## When a movement button is pressed, change to a corresponding State node
func input(event: InputEvent) -> BasePlayerState:
	## If the Player wants ot jump off the wall...
	if Input.is_action_just_pressed("input_jump"):
		return walljump_state
	## If the Player wants to stomp back to the ground...
	if Input.is_action_just_pressed("input_crouch"):
		return stomp_state
	
	return null

## Velocity equasions for this specific state and physics. Unrealated to player Inputs
func physics_process(delta) -> BasePlayerState:
	
	## We need the closest's wall's normal to make the Player run along it.
	player.find_closest_wall_normal()
	
	## The direction of Player movement based on Input
	var input_dir: Vector2 = Input.get_vector("input_left", "input_right", \
	 "input_forwards", "input_backwards")
	## We keep the Y axis the same, and place input_dir on the XZ axis
	player.direction = (player.transform.basis * Vector3(input_dir.x, 0.0, input_dir.y).normalized())
	
	## Decide if the Player going to accelerate or decelerate.
	var temp_accel
	## We use the dot product to see if the Player is facing the direction they are moving in
	if player.direction.dot(Vector3(player.direction.x, 0.0, 0.0)) > 0:
		temp_accel = acceleration
	else:
		temp_accel = deceleration
	
	## Apply velocity, take speed_multiplier and acceleration into account
	player.velocity = player.velocity.lerp((player.direction * player.speed * speed_multiplier), \
	temp_accel * delta)
	
	## Apply gravity (which is the Globals gravity * multiplier)
	## Affected by running on the wall; falling is slowed down by that.
	player.velocity.y -= player.gravity * player.wall_sliding_deceleration * BulletTime.time_scale
	
	
	## If the Player fell off the wall, they start to fall
	if !player.WallDetection.is_colliding():
		return fall_state
		
	## But if they're still clinging to the wall...
	else:
		## If they're on the wall, but they've reached the floor...
		if player.check_for_floor():
			## If the jump button has been pressed within the buffer time, allow for a (floor) jump
			if !player.JumpBufferT.is_stopped():
				return jump_state
				
			## Otherwise (if the Player doesn't take the opportunity to jump)...
			## If the Player stops moving around, return to Idle state. The Y axis is ignored
			elif Vector3(player.velocity.x, 0, player.velocity.z) == Vector3.ZERO:
				return idle_state
			## Otherwise, start walking
			else:
				return walk_state
	
	
	return null
