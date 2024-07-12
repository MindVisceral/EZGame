extends Node3D


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


@export_group("Weapon Bob")

## Enables weaponbob
@export var weapon_bob_enabled: bool = true

## How fast the bob lerps between positions; how fast it returns to original_position from new_pos
@export var bob_multiplier: float = 12
## HERE - similiar to step_interval?


## X-axis bobbing is based on a sine wave
@export_subgroup("Left-Right weapon bob")

## Enables weaponbob on the X axis (moving from left to right and back)
@export var X_axis_bob_enabled: bool = true

## Makes bobbing_node move faster between extremes; bigger number = faster bobbing
@export var x_bob_frequency: float = 0.01
## Makes bobbing_node go further away from original_position; bigger number = wider sine
@export var x_bob_amplitude: float = 0.1


## Z-axis bobbing simply moves the bobbing_node on the Z axis
@export_subgroup("Forwards-Backwards weapon bob")

## Enables weaponbob on the Z axis (moves the bobbing_node slightly forwards, or slightly backwards)
@export var Z_axis_bob_enabled: bool = true

## This length limits how far forwards/backwards the bobbing_node may move
@export var Z_bob_length: float = 0.01


##
@export_subgroup("Up-Down weapon bob")

@export var Y_axis_bob_enabled: bool = true

## This heighht limits how far up/down the bobbing_node may move
@export var Y_bob_height: float = 0.01



###-------------------------------------------------------------------------###
##### Setup functions
###-------------------------------------------------------------------------###

## This Node needs a reference to the Player to access its functions and variables
func init(player: Player) -> void:
	self.player = player

func _ready():
	## Store the bobbing_node's original position; we need that to make it bob
	original_position = bobbing_node.position


###-------------------------------------------------------------------------###
##### Executing functions
###-------------------------------------------------------------------------###

## Applies all weaponbob; _process() is used, because this bobbing is purely visual anyway
func _process(delta: float) -> void:
	
	## If bobbing is enabled...
	if weapon_bob_enabled == true:
		## Calculate a new position for the bobbing_node,
		## and lerp the bobbing_node's position towards that point
		#bobbing_node.position = bobbing_node.position.lerp(do_weapon_bob(delta), \
									#bob_multiplier * delta)
		
		bobbing_node.position = bobbing_node.position.lerp(do_weapon_bob(delta), \
									bob_multiplier * delta)
	


## Move bobbing_node on the X, Y and Z axes when the Player is moving
func do_weapon_bob(delta: float) -> Vector3:
	
	## The position towards which the bobbing_node's position will be lerped
	var new_pos: Vector3
	
	## Get which way the Player is moving based on Input
	## NOTE: This is a Vector2, but we use it along some Vector3-s!
	## Consider its X value to be the X value, and the Y value to be the Z value in 3D space
	## NOTE: input_dir.X is left/right, input_dir.Y is forwards/backwards
	var input_dir: Vector2 = Input.get_vector("input_left", "input_right", \
	 "input_forwards", "input_backwards")
	
		
	## Weaponbob on the X and Z axes only works when the Player is pressing horizontal Input buttons
	## So, if the Player is moving horizontally...
	if input_dir != Vector2.ZERO:
		
		## NOTE: !player.in_air ensures that this only happens when the Player is not in the air
		## Make the bobbing_node move left and right
		new_pos.x = original_position.x + sin(Time.get_ticks_msec() \
							* x_bob_frequency) * x_bob_amplitude * int(!player.in_air)
		## Make the bobbing_node move fowards or backwards
		new_pos.z = original_position.z + input_dir.y * Z_bob_length * int(!player.in_air)
		
		
	## Otherwise, make the bobbing_node return to its original_position
	else:
		new_pos.x = original_position.x
		new_pos.z = original_position.z
	
	## Make the bobbing_node move up or down
	## NOTE: player.in_air ensures that this only happens when the Player is in the air
	new_pos.y = original_position.y + player.velocity.y * Y_bob_height * int(player.in_air)
	
	return new_pos
