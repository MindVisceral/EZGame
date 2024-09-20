class_name PlayerHeadbobHandler
extends Node


###-------------------------------------------------------------------------###
##### Variables and references
###-------------------------------------------------------------------------###

## Reference to the Player, so its functions and variables can be accessed directly
var player: Player


## Actual speed of headbob
var speed: float = 0

## Store original position of bobbing_node, because we will be editing this value
var original_position: Vector3
## Store original rotation of bobbing_node, because we will be editing this value
var original_rotation: Vector3


###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

## A choosen node that will be controlled by the HeadBob script
## Should be set to the BobbingNode Node, but could be set to the Camera itself
## Shouldn't be set to the Head node; that causes a conflict with a piece of code
## in the Player script which rotates the Head with mouse movement.
## This script would nullify that
@export var bobbing_node: Node3D


@export_group("Step Bob")

## Enables headbob when walking (on each "step", we calculate that in this script)
@export var step_bob_enabled: bool = true

## How fast the bob lerps between positions;
## how fast it returns to original_position from new_pos (in seconds)
@export var bob_speed: float = 0.1


## X-axis bobbing is based on a sine wave
@export_subgroup("Left-Right weapon bob")

## Enables WeaponBob on the X axis (moving from left to right and back)
@export var X_axis_bob_enabled: bool = true

## Makes bobbing_node move faster between extremes; bigger number = faster bobbing
@export var x_bob_frequency: float = 0.01
## Makes bobbing_node go further away from original_position; bigger number = wider sine
@export var x_bob_amplitude: float = 0.1


## Y-axis bobbing is based on a sine wave
@export_subgroup("Up-Down weapon bob")

@export var Y_axis_bob_enabled: bool = true

## Makes bobbing_node move faster between extremes; bigger number = faster bobbing
@export var y_bob_frequency: float = 0.02
## Makes bobbing_node go further away from original_position; bigger number = wider sine
@export var y_bob_amplitude: float = 0.1


@export_group("Air Bob")

## Enables headbob while in air
@export var air_bob_enabled: bool = true






## NOTE: Done with an Input.get_vector()
@export_group("Movement Tilt (Quake Like)")

## Speed at which the bobbing_node tilts ()
## How long it takes for the bobbing_node to fully tilt to one direction,
## or return to default position (in seconds)
@export var rotation_speed: float =  0.1

## As the Player moves horizontally, tilt them the way they're moving;
## E.g.: moving forwards - tilt down; moving right - tilt to the right
@export var movement_tilt_enabled: bool = true

## Enable tilting forwards and backwards
@export var movement_tilt_pitch: bool = false
## Enable tilting left and right
@export var movement_tilt_roll: bool = true


## Maxium angle the bobbing_node may be tilted to.
## NOTE: 0.01 is almost imperceivable, 0.05 is very subtle, 0.1 is clearly visible
@export_range(0.01, 0.15, 0.01) var angle_limit_for_tilt: float = 0.05


###-------------------------------------------------------------------------###
##### Setup functions
###-------------------------------------------------------------------------###

## This Node needs a reference to the Player to access its functions and variables
func init(player: Player) -> void:
	self.player = player

func _ready():
	## Store the bobbing_node's original position and rotation;
	## we will be editing that to make bobs happen.
	original_position = bobbing_node.position
	original_rotation = bobbing_node.rotation
	


###-------------------------------------------------------------------------###
##### Executing functions
###-------------------------------------------------------------------------###

## Applies step and jump headbob, and movement tilt
func _process(delta: float) -> void:
	
	## If bobbing is enabled...
	if step_bob_enabled == true:
		
		## Calculate a new position for the bobbing_node,
		## and tween the bobbing_node's position towards that point
		## NOTE: BulletTime.time_scale multiplication happens in the do_head_bob() function
		var bob_tween = get_tree().create_tween()
		bob_tween.tween_property(bobbing_node, "position", do_head_bob(), \
			bob_speed * BulletTime.time_scale)
		
	
	## If air bobbing is enabled...
	if air_bob_enabled == true:
		pass
		
	
	## If movement tilt is enabled...
	if movement_tilt_enabled == true:
		## Calculate a new rotation for the bobbing_node,
		## and tween the bobbing_node's rotation towards that value
		var tilt_tween = get_tree().create_tween()
		tilt_tween.tween_property(bobbing_node, "rotation", movement_tilt(), \
			rotation_speed * BulletTime.time_scale)
			
		
	


## Takes X and Z of input_dir (the horizontal direction the Player is moving in),
## and returns on which axis the bobbing_node should be tilted
func movement_tilt() -> Vector3:
	
	## The rotation towards which the bobbing_node's rotation will be tweened
	var new_rot: Vector3 = original_rotation
	
	## The direction of Player movement based on Input
	var input_dir: Vector2 = Input.get_vector("input_left", "input_right", \
		"input_forwards", "input_backwards")
	
	
	## We multiply the input_dir (if there's movement) by tilt pitch and roll booleans;
	## "roll" is tilting left/right, "pitch" is tilting forwards/backwards
	#
	## 0.0, because we're ignoring the Y axis. That would be head *turning*
	new_rot = Vector3(
		input_dir.y * float(movement_tilt_pitch) * angle_limit_for_tilt, \
		0.0, \
		-input_dir.x * float(movement_tilt_roll) * angle_limit_for_tilt)
		
	
	return new_rot

## Very similiar to regular movement_tilt(), but called by States (from outside of this Script).
## tilt_direction - X value is roll (left/right), Y value is pitch (up/down).
## NOTE: When passing this variable, X and Y must always be either -1, 0, or 1! 
func external_movement_tilt(tilt_direction: Vector2 = Vector2.ZERO) -> void:
	
	## The rotation towards which the bobbing_node's rotation will be tweened
	var new_rot: Vector3 = original_rotation
	
	## We multiply the passed direction by tilt pitch and roll booleans;
	## "roll" is tilting left/right, "pitch" is tilting forwards/backwards
	#
	## 0.0, because we're ignoring the Y axis. That would be head *turning*.
	new_rot = Vector3(
		tilt_direction.y * float(movement_tilt_pitch) * angle_limit_for_tilt, \
		0.0, \
		-tilt_direction.x * float(movement_tilt_roll) * angle_limit_for_tilt)
		
	
	## Calculate a new rotation for the bobbing_node,
	## and tween the bobbing_node's rotation towards that value.
	## NOTE: This normally happens in _process()...
	var tilt_tween = get_tree().create_tween()
	tilt_tween.tween_property(bobbing_node, "rotation", new_rot, \
		rotation_speed * BulletTime.time_scale)
		
	



## Move bobbing_node on the X, Y and Z axes depending on Player Input or velocity
func do_head_bob() -> Vector3:
	
	## NOTE: This is made the same as original_position at first, because if bobbing on an axis
	## NOTE: was disabled or broken, the Head would go to 0 on that axis!
	## The position towards which the bobbing_node's position will be lerped
	var new_pos: Vector3 = original_position
	
	## Get IF the Player is moving based on Input.
	## Could be done with many Input.is_button_pressed()-s, but this is cleaner.
	var input_dir: Vector2 = Input.get_vector("input_left", "input_right", \
		"input_forwards", "input_backwards")
	
	## HeadBob on the X axis only works when the Player is pressing horizontal Input buttons...
	if input_dir != Vector2.ZERO:
		## NOTE: !player.in_air ensures that this only happens when the Player is NOT in the air
		## NOTE: !player.on_wall ensures that this only happens when the Player is NOT on a wall
		
		## If bobbing on X axis is enabled...
		if X_axis_bob_enabled == true:
			## Make the bobbing_node move left and right
			new_pos.x = original_position.x + (sin(Time.get_ticks_msec() * BulletTime.time_scale \
				* x_bob_frequency) * x_bob_amplitude * \
				int(!player.in_air) * int(!player.on_wall)) * int(player.headbob_active)
				
			
		
		## If bobbing on Y axis is enabled...
		if Y_axis_bob_enabled == true:
			## Make the bobbing_node move up and down
			new_pos.y = original_position.y + (sin(Time.get_ticks_msec() * BulletTime.time_scale \
				* y_bob_frequency) * y_bob_amplitude * \
				int(!player.in_air) * int(!player.on_wall)) * int(player.headbob_active)
				
			
		
	
	## HERE: This proves annoying. Code segment is prime for removal.
	#
	### NOTE: This happens no matter if the Player is on the ground or in the air
	### If bobbing on Z axis is enabled...
	#if Z_axis_bob_enabled == true:
		### NOTE: player.velocity.z could be input_dir.y, but there seems to be not much difference
		### Make the bobbing_node move fowards or backwards
		#new_pos.z = original_position.z + (player.velocity.z * Z_bob_length)
	
	
	return new_pos
