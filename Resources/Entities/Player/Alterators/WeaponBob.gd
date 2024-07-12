extends Node


###-------------------------------------------------------------------------###
##### Variables and references
###-------------------------------------------------------------------------###

## Reference to the Player, so its functions and variables can be accessed directly
var player: Player


## Store original position of bobbing_node, because we will be editing this value
var original_position: Vector3 = Vector3(0.0, 0.0, 0.0)
## No rotation! A weapons animation is responsible for that.

### Value to be added to compute a step, each frame that the character is walking this value 
### is added to a counter
### Ignore that mumbo-jumbo above. Bigger number == each step takes longer to get to the next step
var step_interval: float = 6.0 * 2
## HERE - Could this replace bob_multiplier to sync with HeadBob step_interval?


###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

## A choosen node that will be controlled by the WeaponBob script
## Should be set to the Firearms Node
@export var bobbing_node: Node3D


@export_group("Step Bob")

## Enables weaponbob when walking (on each "step", we calculate that in this script)
@export var step_bob_enabled: bool = true

## How fast the bob lerps between positions; how fast it returns to original_position from new_pos
@export var bob_multiplier: float = 12
## HERE - similiar to step_interval?


##
@export_subgroup("Left-Right weapon bob")

## Enables weaponbob on the X axis (moving from left to right and back)
@export var X_axis_bob_enabled: bool = true

## NOTE: This X-axis bobbing is based on a sine wave!
## Makes bobbing_node move faster between extremes; bigger number = faster bobbing
@export var x_bob_frequency: float = 0.01
## Makes bobbing_node go further away from original_position; bigger number = wider sine
@export var x_bob_amplitude: float = 0.1

##
@export_subgroup("Forwards-Backwards weapon bob")

@export var Z_axis_bob_enabled: bool = true

## This Z-axis bobbing moves the bobbing_node on the Z axis,
## based on Player Input on the Z axis, limited by this length
@export var Z_bob_length: float = 0.01


@export_group("Jump Bob")

## Enables bob for jumps made
@export var jump_bob_enabled: bool = true


##
@export_subgroup("Up-Down weapon bob")

@export var Y_axis_bob_enabled: bool = true



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
			bobbing_node.position = bobbing_node.position.lerp(do_weapon_bob(delta), bob_multiplier * delta)
		
		## When not on ground anymore, reset bob   ##HERE - temporary?
		else:
			bobbing_node.position = bobbing_node.position.lerp(original_position, bob_multiplier * delta)
	
	
	
	
	## If a bob on jump is enabled...
	if jump_bob_enabled:
		## This type of weaponbob is only applied if the Player is in the air
		if player.in_air == true:
			pass ## HERE - do this part
			
		
	
	
	## Bobbing calculations are done, apply new_position to the bobbing_node
	## NOTE: Every frame we reset bobbing_node to original_position,
	## then we calculate new_position, and teleport the bobbing_node there;
	## it's only an illusion of moving from new_position to new_position
	#bobbing_node.position = new_position


## Move bobbing_node on the X, Y and Z axes when the Player is moving
func do_weapon_bob(delta: float) -> Vector3:
	
	## The position towards which the bobbing_node's position will be lerped
	var new_pos: Vector3
	
	## Get which way the Player is moving in 3D space based on Input
	var input_dir: Vector2 = Input.get_vector("input_left", "input_right", \
	 "input_forwards", "input_backwards")
	## Without the Y axis
	var horizontal_velocity: Vector3 = Vector3(input_dir.x, 0, input_dir.y)
	
	## Weaponbob on the X axis only works when the Player is pressing horizontal Input buttons
	## [and on the ground - check _physics_process]
	if horizontal_velocity != Vector3.ZERO:
		
		## Make the bobbing_node move left and right
		new_pos.x = original_position.x + sin(Time.get_ticks_msec() \
											* x_bob_frequency) * x_bob_amplitude
		new_pos.z = original_position.z + horizontal_velocity.z * Z_bob_length
		
		## HERE - temporary
		new_pos.y = original_position.y
		
	## Otherwise, make the bobbing_node move towards its original_position
	else:
		
		new_pos.x = original_position.x
		new_pos.z = original_position.z
		
		## HERE - temporary
		new_pos.y = original_position.y
	
	return new_pos
