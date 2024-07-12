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

## Actual cycle x of step headbob
var cycle_position_x: float = 0

## Actual cycle x of step headbob
var cycle_position_y: float = 0

### Value to be added to compute a step, each frame that the character is walking this value 
### is added to a counter
### Ignore that mumbo-jumbo above. Bigger number == each step takes long to get to the next step
var step_interval: float = 6.0 * 2
## HERE - Test ^this^, maybe there's a better value


###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

## A choosen node that will be controlled by the HeadBob script
## Should be set to the BobbingNodenode, but could be set to the Camera itself
## Shouldn't be set to the Head node; that causes a conflict with a piece of code
## in the Player script which rotates the Head with mouse movement.
## This script would nullify that
@export var bobbing_node: Node3D


@export_group("Step Bob")

## Enables headbob when walking (on each "step", we calculate that in this script)
@export var step_bob_enabled: bool = true

## Maximum range (deviation?) value of headbob
@export var bob_range: Vector2 = Vector2(0.07, 0.07)

## Curve that makes the bob happen; value is to be kept between -1 and 1
## Positive value translates to going up and to the right of original_position, and vice versa
@export var bob_curve: Curve

## Bigger number, bigger oscillations up/down and right/left
@export var curve_multiplier: Vector2 = Vector2(2,2)

## Dictates how fast the bobbing_node moves on the Y axis in comparison to the X axis
## If the number is low, the vertical movement is slower, and vice versa
## Keep at about 2 - the movement seems to be equal then
@export var vertical_horizontal_ratio: float = 2


@export_group("Jump Bob")

## Enables bob for jumps made
@export var jump_bob_enabled: bool = true

## Resource that stores information from bob lerp jump
#@export var timed_bob_curve: TimedBobCurve


## NOTE: Done with an Input.get_vector()
@export_group("Movement Tilt (Quake Like)")

## As the Player moves horizontally, tilt them the way they're moving;
## E.g.: moving forwards - tilt down; moving right - tilt to the right
@export var movement_tilt_enabled: bool = true

## Enable tilting forwards and backwards
@export var movement_tilt_pitch: bool = true

## Enable tilting left and right
@export var movement_tilt_roll: bool = true

## Speed at which the bobbing_node tilts
@export var speed_rotation: float= 4.0

## Maxium angle we will tilt the bobbing_node to
@export_range(0.01, 0.15, 0.01) var angle_limit_for_tilt: float = 0.05
## ^^0.01 is almost imperceivable, 0.05 is very subtle, 0.1 is clearly visible^^


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
func _physics_process(delta: float) -> void:
	## The direction of Player movement based on Input
	var input_dir: Vector2 = Input.get_vector("input_forwards", "input_backwards", \
		"input_left", "input_right",)
	
	## Reset the new_position, we will calculate it soon
	var new_position = original_position
	var new_rotation = original_rotation
	
	
	## If bobbing on steps is enabled...
	if step_bob_enabled == true:
		## This type of headbob is only applied if the Player is walking
		if player.in_air == false:
			## Calculate a new position for the bobbing_node
			new_position += _do_head_bob(delta)
		
	## If a bob on jump is enabled...
	if jump_bob_enabled:
		## This type of headbob is only applied if the Player is in the air
		if player.in_air == true:
			if player.velocity.y > 0:
				## The bobbing_node is moved down when going up
				pass ## HERE - do this part
			
		
	
	## If movement tilt is enabled...
	if movement_tilt_enabled == true:
		## ...we add this tilt to the rotation.
		#
		## We multiply the input_dir by these two tilt booleans;
		## "roll" is tilting left/right, "pitch" is tilting forwards/backwards
		#
		## If roll/pitch is true, its respective input_dir is multiplied by 1,
		## so the value doesn't change, and therefore tilting does happen;
		## If roll/pitch is false, its respective input_dir is multiplied by 0,
		## so the value becomes 0, and tilting doesn't happen;
		new_rotation += _movement_tilt(input_dir.x * float(movement_tilt_roll), \
			input_dir.y * float(movement_tilt_pitch), delta)
	
	
	## Bobbing calculations are done, apply bobbing to the bobbing_node
	bobbing_node.position = new_position
	bobbing_node.rotation = new_rotation


## Takes X and Z of input_dir (the horizontal direction the Player is moving in),
## and returns on which axis the bobbing_node should be tilted
func _movement_tilt(x, z, delta) -> Vector3:
	## 0.0, because we're ignoring the Y axis. That would be head *turning*
	var target_tilt = Vector3(x * angle_limit_for_tilt, 0.0, -z * angle_limit_for_tilt)
	return lerp(bobbing_node.rotation, target_tilt, speed_rotation * delta)


func _do_head_bob(delta: float) -> Vector3:
	## As the name says, get Player's velocity Vector, but without the Y axis
	## We use it to get tick_speed
	var horizontal_velocity = Vector3(player.velocity.x, 0, player.velocity.z)
	
	## Calculate the bobbing_node's new position as we move through the curve
	var x_pos = (bob_curve.sample(cycle_position_x) * curve_multiplier.x * bob_range.x)
	var y_pos = (bob_curve.sample(cycle_position_y) * curve_multiplier.y * bob_range.y)
	
	## No idea how the following lines work, but they just do
	var tick_speed = (horizontal_velocity.length() * delta) / step_interval
	cycle_position_x += tick_speed
	cycle_position_y += tick_speed * vertical_horizontal_ratio
	
	if(cycle_position_x > 1):
		cycle_position_x -= 1
	if(cycle_position_y > 1):
		cycle_position_y -= 1
	
	return Vector3(x_pos, y_pos, 0)

## Reset head bob step cycles
func reset_head_bob_cycles(): ## HERE - not used
	cycle_position_x = 0
	cycle_position_y = 0
