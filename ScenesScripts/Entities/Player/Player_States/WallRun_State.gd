extends BasePlayerState

@export_group("Tilting")

## The Player tilts left/right when WallRunning, depending on where they're looking when doing so.
## This variable controls how far away *from* the wall Player may look before tilting is disabled.
## 90 degrees is, in practise, full 180 degrees.
## NOTE: Refer to ("res://DesignReferences/WallRun_tilt_reference.png") for visualization.
@export_range(0.0, 90.0, 0.1) var player_to_wall_tilt_angle: float = 45.0
## NOTE: This might be difficult to understand, and the axplanation is bad,
## NOTE: but this was much easier to code in the moment.


@export_group("Movement")

## Time for the Player to reach full speed
@export var acceleration: float = 8.0
## Time for the Player to stop in place
@export var deceleration: float = 8.0
## Speed while in this state
@export_range(0.1, 2.0, 0.05) var speed_multiplier: float = 1.4


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
	
	## Reset Player's tilting back to normal.
	player.HeadBob.external_movement_tilt()


## When a movement button is pressed, change to a corresponding State node
func input(event: InputEvent) -> BasePlayerState:
	## If the Player wants ot jump off the wall...
	if Input.is_action_just_pressed("input_jump"):
		return walljump_state
	## If the Player wants to stomp back to the ground...
	if Input.is_action_just_pressed("input_slide"):
		return stomp_state
	
	return null

## Tilting the Player Camera left/right depending on their relation to the nearest wall
## is handled here.
func process(delta: float) -> BasePlayerState:
	
	
	## Tilt the Camera away from the Wall a little when WallRunning;
	## the value of angle_limit_for_tilt is used.
	## Check HeadBob Node for details.
	
	## Imagine the scene from the top, looking down at the Player - we ignore the Y axis.
	#
	## Get Player's basis' X and Z values - this is the (global) direction the Player is looking in
	var player_basis_vector2: Vector2 = Vector2(player.global_transform.basis.z.x, \
		player.global_transform.basis.z.z)
	
	## Get the closest wall's normal value. Again, ignore Y axis - will save us some headaches.
	var closest_wall_normal: Vector3 = player.find_closest_wall_normal()
	var closest_wall_normal_vector2: Vector2 = Vector2(closest_wall_normal.x, \
		closest_wall_normal.z)
	
	## With those above Vector2s, we get the angle between the player's 'look' direction and
	## the wall's normal (in radians!)
	var look_angle: float = player_basis_vector2.angle_to(closest_wall_normal_vector2)
	## We convert that to degrees, since that's easier to understand.
	var angle_deg: float = rad_to_deg(look_angle)
	
	## Now we compare. I don't think I can explain this properly. Just know that '90.0'
	## is Player's RIGHT side, and '-90.0' is LEFT. You might be better off tweaking the values.
	#
	## This means that the Wall is on the Player's Right
	if angle_deg > (90.0 - player_to_wall_tilt_angle) and \
			angle_deg < (90.0 + player_to_wall_tilt_angle):
		
		## Tilt the Player's Camera to the Left, away from the wall.
		player.HeadBob.external_movement_tilt(Vector2.LEFT)
		
	## This means that the Wall is on the Player's Left
	elif angle_deg > (-90.0 - player_to_wall_tilt_angle) and \
			angle_deg < (-90.0 + player_to_wall_tilt_angle):
		
		## Tilt the Player's Camera to the Right, away from the wall.
		player.HeadBob.external_movement_tilt(Vector2.RIGHT)
		
	## This means that the Wall is in front or behind the Player
	else:
		## Reset tilting back to default - that means no tilt.
		player.HeadBob.external_movement_tilt(Vector2.ZERO)
		
	
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
	## Affected by running on the wall; falling is slowed down by that.
	## NOTE: Without BulletTime.time_scale, jumping is inconsistent when BulletTime is activated
	player.velocity.y -= player.gravity * player.wall_sliding_deceleration * \
						BulletTime.time_scale * delta
	## Clamp the velocity to be falling_speed_limit at most.
	## NOTE: maxf is used because velocity.y is negative when falling
	player.velocity.y = maxf(player.velocity.y, player.falling_speed_limit)
	
	
	## If the Player isn't clinging to a wall, they start to fall
	if !player.WallDetection.is_colliding() or !player.is_moving_at_wall(true):
		print("wallrun failed")
		return fall_state
		
	## But if they're still clinging to the wall...
	else:
		## If they're on the wall, but they've reached the floor...
		if player.is_player_on_floor():
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
