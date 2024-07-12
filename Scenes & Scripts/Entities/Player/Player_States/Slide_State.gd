extends BasePlayerState

@export_group("Movement")
#
## Time for the Player to reach full speed
@export var acceleration: float = 14.0
## Time for the Player to stop in place
@export var deceleration: float = 16.0
## Speed while in this state
@export var speed_multiplier: float = 1.4


@export_group("States")
#
@export var idle_state: BasePlayerState
@export var walk_state: BasePlayerState
@export var jump_state: BasePlayerState
@export var fall_state: BasePlayerState

func enter() -> void:
	super.enter()
	
	## TODO: Player height should change when sliding
	### Alter the total height to crouch height - defined in the Player script
	#player.HeightAlternator.alter_height(player.crouch_height, player.crouch_feet_height, \
		#player.crouch_FloorCast_height, player.crouch_head_height)
	
	player.HeightAlternator.alter_collider_height(player.crouch_height)
	
	calculate_slide_direction()

func exit() -> void:
	super.exit()
	
	### Alter the total height to default height - defined in the Player script
	#player.HeightAlternator.alter_height(player.default_height, player.default_feet_height, \
		#player.default_FloorCast_height, player.default_head_height)
	
	player.HeightAlternator.alter_collider_height(player.standing_height)

## When a movement button is pressed, change to a corresponding State node
func input(event: InputEvent) -> BasePlayerState:
	## Jump from the Slide
	if Input.is_action_just_pressed("input_jump"):
		return jump_state
	## HERE: not necessary?
	## When the Slide button isn't pressed anymore, we return to the idle_state
	elif !Input.is_action_pressed("input_slide"):
		return idle_state
	
	return null

## Velocity equasions for this specific state and physics. Unrealated to player Inputs
func physics_process(delta) -> BasePlayerState:
	
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
	
	## Apply gravity (which is the Globals' gravity * multiplier)
	player.velocity.y -= player.gravity * BulletTime.time_scale * delta
	
	## If we slide off a floor, we still continue sliding
	#if !player.is_on_floor():
		#return fall_state
	
	## If the Player stops moving, return to Idle state. The Y axis is ignored
	if Vector3(player.velocity.x, 0, player.velocity.z) == Vector3.ZERO:
		return idle_state
	
	return null


## When the Slide State is first entered, we must check the direction of the Slide
func calculate_slide_direction() -> void:
	pass
