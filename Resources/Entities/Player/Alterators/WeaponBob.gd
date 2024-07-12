extends Node

## Makes sine go faster
@export var bob_speed: float = 0.01
## Sine amplitude
@export var bob_width: float = 0.1
## How fast the bob lerps between positions
@export var bob_multiplier: float = 12

###-------------------------------------------------------------------------###
##### Variables and references
###-------------------------------------------------------------------------###

## Reference to the Player, so its functions and variables can be accessed directly
var player: Player


## Actual speed of weaponbob
var speed: float = 0

## Store original position of bobbing_node, because we will be editing this value
var original_position: Vector3 = Vector3(0.0, 0.0, 0.0)
## No rotation! A weapons animation is responsible for that.

## Actual cycle x of step weaponbob
## Current point on the bob_curve. Changes over time
var cycle_position_x: float = 0.0
## Actual cycle y of step weaponbob
var cycle_position_y: float = 0.0
## Actual cycle z of step weaponbob
var cycle_position_z: float = 0.0

### Value to be added to compute a step, each frame that the character is walking this value 
### is added to a counter
### Ignore that mumbo-jumbo above. Bigger number == each step takes longer to get to the next step
var step_interval: float = 6.0 * 2
## HERE - Test ^this^, maybe there's a better value


###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

## A choosen node that will be controlled by the WeaponBob script
## Should be set to the Firearms Node
@export var bobbing_node: Node3D


@export_group("Step Bob")

## Enables weaponbob when walking (on each "step", we calculate that in this script)
@export var step_bob_enabled: bool = true

## Maximum range (deviation?) value of weaponbob
@export var bob_range: Vector3 = Vector3(0.07, 0.07, 0.07)

## Curve that makes the bob happen; value is to be kept between -1 and 1
## Positive value translates to going up and to the right of original_position, and vice versa
@export var bob_curve: Curve

## Bigger number, bigger oscillations up/down and right/left
@export var curve_multiplier: Vector3 = Vector3(2.0, 2.0, 2.0)


@export_group("Jump Bob")

## Enables bob for jumps made
@export var jump_bob_enabled: bool = true

## Resource that stores information from bob lerp jump
#@export var timed_bob_curve: TimedBobCurve


###-------------------------------------------------------------------------###
##### Setup functions
###-------------------------------------------------------------------------###

## This Node needs a reference to the Player to access its functions and variables
func init(player: Player) -> void:
	self.player = player

func _ready():
	## Store the bobbing_node's original position;
	## we will be editing that to make bobs happen.
	original_position = bobbing_node.position
	#original_position = Vector3(float(bobbing_node.position.x), float(bobbing_node.position.y), float(bobbing_node.position.z))
	print(bobbing_node.position)


###-------------------------------------------------------------------------###
##### Executing functions
###-------------------------------------------------------------------------###

## Applies step and jump weaponbob
func _physics_process(delta: float) -> void:
	
	## If bobbing on steps is enabled...
	if step_bob_enabled == true:
		## This type of weaponbob is only applied if the Player is on the ground
		if player.in_air == false:
			## Calculate a new position for the bobbing_node
			#bobbing_node.position += _do_weapon_bob(delta)
			bobbing_node.position = bobbing_node.position.lerp(better_bob(delta), delta * bob_multiplier)
			
			print(bobbing_node.position.x)
		
		## When jumped, reset bob  ##HERE - temporary, do this for jump_bob_enabled
		else:
			bobbing_node.position = bobbing_node.position.lerp(original_position, delta * bob_multiplier)
	
	
	
	
	## If a bob on jump is enabled...
	if jump_bob_enabled:
		## This type of weaponbob is only applied if the Player is in the air
		if player.in_air == true:
			if player.velocity.y > 0:
				## The bobbing_node is moved down when going up
				pass ## HERE - do this part
			
		
	
	
	
	
	## Bobbing calculations are done, apply new_position to the bobbing_node
	## NOTE: Every frame we reset bobbing_node to original_position,
	## then we calculate new_position, and teleport the bobbing_node there;
	## it's only an illusion of moving from new_position to new_position
	#bobbing_node.position = new_position


func _do_weapon_bob(delta: float) -> Vector3:
	## As the name says, get Player's velocity Vector, but without the Y axis
	## We use it to get tick_speed
	var horizontal_velocity = Vector3(player.velocity.x, 0, player.velocity.z)
	#var horizontal_velocity: Vector3 = player.velocity
	
	## Calculate the bobbing_node's new position as we move through the curve
	var x_pos = (bob_curve.sample(cycle_position_x) * curve_multiplier.x * bob_range.x)
	var y_pos = (bob_curve.sample(cycle_position_y) * curve_multiplier.y * bob_range.y)
	var z_pos = (bob_curve.sample(cycle_position_z) * curve_multiplier.z * bob_range.z)
	
	## Move the cycle by tick_speed so that the _pos variables will move smoothly next frame
	var tick_speed = (horizontal_velocity.length() * delta) / step_interval
	
	
	cycle_position_x += tick_speed
	cycle_position_y += tick_speed
	cycle_position_z += tick_speed
	
	if(cycle_position_x > 1):
		cycle_position_x -= 1
	if(cycle_position_y > 1):
		cycle_position_y -= 1
	if(cycle_position_z > 1):
		cycle_position_z -= 1
	
	## x_pos is left/right, y_pos is up/down, z_pos is forwards/backwards
	return Vector3(x_pos, y_pos, z_pos)


## 
func better_bob(delta: float) -> Vector3:
	
	## The position towards which the bobbing_node's position will be lerped
	var new_pos: Vector3
	
	## Get which way the Player is moving in 3D space based on Input
	var input_dir: Vector2 = Input.get_vector("input_left", "input_right", \
	 "input_forwards", "input_backwards")
	## Without the Y axis
	var horizontal_velocity: Vector3 = Vector3(input_dir.x, 0, input_dir.y)
	
	## Weaponbob on the X axis only works when the Player is moving
	## [and on the ground - check _physics_process]
	if horizontal_velocity != Vector3.ZERO:
		
		## Make the bobbing_node move left and right
		new_pos.x = original_position.x + sin(Time.get_ticks_msec() * bob_speed) * bob_width
		## HERE - temporary
		new_pos.y = original_position.y
		new_pos.z = original_position.z
		
	## Otherwise, make the bobbing_node move towards its original_position
	else:
		
		new_pos.x = original_position.x
		## HERE - temporary
		new_pos.y = original_position.y
		new_pos.z = original_position.z
	
	return new_pos




## Reset weaponbob step cycles
func reset_head_bob_cycles(): ## HERE - not used
	#cycle_position_x = 0
	#cycle_position_y = 0
	#cycle_position_z = 0
	
	pass
