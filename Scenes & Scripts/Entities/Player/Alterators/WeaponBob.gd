class_name PlayerWeaponbobHandler
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


@export_group("Weapon Bob")

## Enables WeaponBob in general
@export var weapon_bob_enabled: bool = true
## How fast the bob lerps between positions; how fast it returns to original_position from new_pos
@export var bob_multiplier: float = 12
## HERE - similiar to step_interval?


## X-axis bobbing is based on a sine wave
@export_subgroup("Left-Right weapon bob")

## Enables WeaponBob on the X axis (moving from left to right and back)
@export var X_axis_bob_enabled: bool = true

## Makes bobbing_node move faster between extremes; bigger number = faster bobbing
@export var X_bob_frequency: float = 0.01
## Makes bobbing_node go further away from original_position; bigger number = wider sine
@export var X_bob_amplitude: float = 0.1


## Z-axis bobbing simply moves the bobbing_node on the Z axis
@export_subgroup("Forwards-Backwards weapon bob")

## Enables WeaponBob on the Z axis (moves the bobbing_node slightly forwards, or slightly backwards)
@export var Z_axis_bob_enabled: bool = true

## This length limits how far forwards/backwards the bobbing_node may move
@export var Z_bob_length: float = 0.01


## Y-axis bobbing is based on a sine wave
@export_subgroup("Up-Down weapon bob")

@export var Y_axis_bob_enabled: bool = true

## This height limits how far up/down the bobbing_node may move
@export var Y_bob_height: float = 0.003


@export_group("Breath Bob")

## Enables Breathing Bobbing in general
@export var breath_enabled: bool = true
## How fast the bob lerps between positions; how fast it returns to original_position from new_pos
@export var breath_multiplier: float = 10

## Makes bobbing_node move faster between extremes; bigger number = faster breathing
@export var breath_frequency: float = 0.005
## Makes bobbing_node go further away from original_position; bigger number = wider sine
@export var breath_amplitude: float = 0.003






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

## Applies all WeaponBob; _process() is used, because this bobbing is purely visual anyway
func _process(delta: float) -> void:
	
	## If bobbing is enabled...
	if weapon_bob_enabled == true:
		## Calculate a new position for the bobbing_node,
		## and tween the bobbing_node's position towards that point
		var bob_tween = get_tree().create_tween()
		bob_tween.tween_property(bobbing_node, "position", do_weapon_bob(), \
										bob_multiplier * BulletTime.time_scale * delta)
	
	## If breathing is enabled...
	if breath_enabled == true:
		## Calculate a new position for the bobbing_node,
		## and tween the bobbing_node's position towards that point
		var breath_tween = get_tree().create_tween()
		breath_tween.tween_property(bobbing_node, "position", do_breathing(), \
										breath_multiplier * BulletTime.time_scale * delta)


## Move bobbing_node on the X, Y and Z axes depending on Player Input or velocity
func do_weapon_bob() -> Vector3:
	
	## NOTE: This is made the same as original_position at first, because if bobbing on an axis
	## NOTE: was disabled or broken, the weapon would go to 0 on that axis!
	## The position towards which the bobbing_node's position will be lerped
	var new_pos: Vector3 = original_position
	
	## Get IF the Player is moving based on Input.
	## Could be done with many Input.is_button_pressed()-s, but this is cleaner.
	var input_dir: Vector2 = Input.get_vector("input_left", "input_right", \
	 "input_forwards", "input_backwards")
	
	## WeaponBob on the X axis only works when the Player is pressing horizontal Input buttons...
	if input_dir != Vector2.ZERO:
		## NOTE: !player.in_air ensures that this only happens when the Player is NOT in the air
		## If bobbing on X axis is enabled...
		if X_axis_bob_enabled == true:
			## Make the bobbing_node move left and right
			new_pos.x = original_position.x + \
				## we take 
				(input_dir.length() * \
				sin(Time.get_ticks_msec() * X_bob_frequency) * X_bob_amplitude * int(!player.in_air))
	
	## NOTE: This happens no matter if the Player is on the ground or in the air
	## If bobbing on Z axis is enabled...
	if Z_axis_bob_enabled == true:
		## Make the bobbing_node move fowards or backwards
		new_pos.z = original_position.z + (input_dir.y * Z_bob_length)
	
	## NOTE: player.in_air ensures that this only happens when the Player IS in the air
	## If bobbing on Y axis is enabled...
	if Y_axis_bob_enabled == true:
		## Make the bobbing_node move up or down
		new_pos.y = original_position.y + (player.velocity.y * Y_bob_height * int(player.in_air))
	
	
	return new_pos


## Move bobbing_node on the Y axis to simulate breathing
func do_breathing() -> Vector3:
	
	## NOTE: This is made the same as original_position at first, because if something was broken,
	## the weapon would go to 0 on the Y axis!
	## The position towards which the bobbing_node's position will be lerped
	var new_pos: Vector3 = original_position
	
	## Make the bobbing_node move up and down slightly
	new_pos.y = original_position.y + \
		(sin(Time.get_ticks_msec() * breath_frequency) * breath_amplitude)
	
	## We only edited the Y axis, but returning a Vector3 is much simpler and less buggy
	return new_pos
