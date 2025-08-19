extends BasePlayerState

@export_group("Movement")

## Dash length in seconds
@export_range(0.05, 4.0, 0.05) var dash_length: float = 0.1
## Dash ldistance in meters
@export_range(0.05, 50.0, 0.05) var dash_distance: float = 5.0


@export_group("States")
#
@export var idle_state: BasePlayerState
@export var walk_state: BasePlayerState
@export var dash_state: BasePlayerState
@export var jump_state: BasePlayerState
@export var fall_state: BasePlayerState


## This holds the direction in which the Player will dash
## Set by calculate_dash_direction()
var dash_direction: Vector3 = Vector3.ZERO


func enter() -> void:
	super.enter()
	
	## We want the Player to slide in the direction they are looking in,
	## at the moment of entering the slide state
	dash_direction = calculate_dash_direction()
	player.direction = dash_direction
	
	## Dash velocity based on direction, dash length and distance
	## NOTE: This is based on the formula for velocity (v = d / t)
	player.velocity = dash_direction * (dash_distance / dash_length)
	
	## The Dash should only last a short time
	await get_tree().create_timer(dash_length).timeout
	cancel_dash()
	

func exit() -> void:
	super.exit()
	

## When a movement button is pressed, change to a corresponding State node
func input(event: InputEvent) -> BasePlayerState:
	## Another dash
	if Input.is_action_just_pressed("input_dash"):
		return dash_state
		
	
	return null

## Velocity equasions for this specific state and physics. Unrealated to player Inputs
func physics_process(delta: float) -> BasePlayerState:
	
	## Normalize the direction here since calculate_dash_direction() doesn't do that by itself.
	player.direction = player.direction.normalized()
	
	## Apply velocity, take speed_multiplier and deceleration into account
	## NOTE: Lerping player.velocity itself would also impact vertical (y) velocity,
	## NOTE: so we lerp X and Z separately instead.
	player.velocity.x = lerpf(player.velocity.x, (player.direction.x * player.speed), delta)
	player.velocity.z = lerpf(player.velocity.z, (player.direction.z * player.speed), delta)
	
	
	## If the Player stops moving, return to Idle state. The Y axis is ignored
	if Vector3(player.velocity.x, 0.0, player.velocity.z).is_zero_approx():
		return idle_state
	
	return null


## When the Dash State is first entered, we must check which direction the Player will go in
## If the Player is holding down a directional movement key, then they will slide in that direction.
## Otherwise they slide in the direction they are looking at.
func calculate_dash_direction() -> Vector3:
	## Temporary return vector
	var return_vector: Vector3
	
	## The direction of Player movement based on Input
	var input_dir: Vector2 = Input.get_vector("input_left", "input_right", \
		"input_forwards", "input_backwards")
		
	
	
	## Input takes priority,
	if input_dir:
		## Take Input and use it to determine Player movement in relation to the world.
		## We ignore the Y axis, and place input_dir on the XZ axis
		return_vector = (player.transform.basis * Vector3(input_dir.x, 0.0, input_dir.y).normalized())
		
	## ...but if there is no Input...
	else:
		## Make the Player's direction be the same as their rotation on the Y axis,
		## (which changes with horizontal mouse movement in the Player script)
		## NOTE: I stole this piece of code, I have no idea how it (or the principle behind it) work
		## I guess sin and cos transform the rotation into the right Vector?
		## NOTE: This Vector is NEGATIVE! This doesn't work otherwise.
		return_vector = -Vector3(sin(player.rotation.y), 0, cos(player.rotation.y))
		
	
	
	## Return the Vector3 we just determined
	return return_vector


## Used when the Dash should be stopped - dash length is over, hit a wall, etc.
func cancel_dash() -> void:
	state_manager.change_state(idle_state)
