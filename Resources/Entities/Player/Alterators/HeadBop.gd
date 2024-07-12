extends Node
class_name HeadBop


## A choosen node that will be controlled by the HeadBop script
## Should be set to the Head node, but could be set to the Camera itself too
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
@export var timed_bob_curve: TimedBobCurve


## Note: Done with an Input.get_vector()
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


func _ready():
	## Store the bobbing_node's original position and rotation;
	## we will be editing that to make bobs happen.
	original_position = bobbing_node.position
	original_rotation = bobbing_node.rotation


## Applies step and jump headbob, and movement tilt
func head_bob_process(horizontal_velocity: Vector3, is_on_floor: bool, _delta: float):
	
	## Fucking bastard
	var input_dir: Vector2 = Input.get_vector("input_forwards", "input_backwards", \
		"input_left", "input_right",)
	
	
	
	if timed_bob_curve:
		timed_bob_curve.bob_process(_delta)
	
	## Reset the new_position, we will calculate it soon
	var new_position = original_position
	var new_rotation = original_rotation
	## If bobbing on steps is enabled...
	if step_bob_enabled:
		## Calculate a new position
		var headpos = _do_head_bob(horizontal_velocity.length(), _delta)
		if is_on_floor:
			new_position += headpos
		
	## 
	if timed_bob_curve:
		timed_bob_curve.y -= timed_bob_curve.offset
	
	## If movement tilt is enabled...
	if movement_tilt_enabled:
		## ...we add this tilt to the rotation.
		#
		## We multiply the input_dir by these tilt booleans;
		## If roll/pitch is true, its respective input_dir is multiplied by 1,
		## so the value doesn't change, and therefore we allow for tilting;
		## If roll/pitch is false, its respective input_dir is multiplied by 0,
		## so the value becomes a 0 and tilting doesn't happen;
		#
		## "roll" is tilting left/right, "pitch" is tilting forwards/backwards
		new_rotation += _movement_tilt(input_dir.x * float(movement_tilt_roll), \
			input_dir.y * float(movement_tilt_pitch), _delta)
	
	
	bobbing_node.position = new_position
	bobbing_node.rotation = new_rotation


## Apply jump headbob - applied by the Jump state
func do_jump_bob():
	if timed_bob_curve:
		timed_bob_curve.do_bob_cycle()


## Resets head bob step cycles
## Used when we do a jump bob
func reset_cycles():
	cycle_position_x = 0
	cycle_position_y = 0


## Takes X and Z of input_dir (the horizontal direction the Player is moving in),
## and returns on which axis the bobbing_node should be tilted
func _movement_tilt(x, z, _delta) -> Vector3:
	## 0.0, because we're ignoring the Y axis
	var target_tilt = Vector3(x * angle_limit_for_tilt, 0.0, -z * angle_limit_for_tilt)
	return lerp(bobbing_node.rotation, target_tilt, speed_rotation * _delta)


func _do_head_bob(speed: float, delta: float) -> Vector3:
	## Calculate the bobbing_node's new position as we move through the curve
	var x_pos = (bob_curve.sample(cycle_position_x) * curve_multiplier.x * bob_range.x)
	var y_pos = (bob_curve.sample(cycle_position_y) * curve_multiplier.y * bob_range.y)
	
	## No idea how the following lines work, but they just do
	var tick_speed = (speed * delta) / step_interval
	cycle_position_x += tick_speed
	cycle_position_y += tick_speed * vertical_horizontal_ratio
	
	if(cycle_position_x > 1):
		cycle_position_x -= 1
	if(cycle_position_y > 1):
		cycle_position_y -= 1
	
	return Vector3(x_pos, y_pos, 0)
