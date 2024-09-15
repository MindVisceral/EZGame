class_name flamethrower
extends FirearmBase
## NOTE: This is a WIELDABLE weapon only meant to be handled by the Player!
## NOTE: Enemies get their own weapons, and 'pickupable' weapons are another thing entirely.


###-------------------------------------------------------------------------###
##### References
###-------------------------------------------------------------------------###

## The Player's Camera3D Node. Used to get the direction in which the Player is looking.
@export var player_camera: Camera3D

## Reference to the Flame "bullet" - Flamethrower fires these RigidBodies; they serve as Bullets.
@export var flame_bullet: PackedScene

## fire_bullet "Bullets" come out of this Marker
@export var nuzzle: Marker3D

###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

@export_group("Weapon parameters")

##



###-------------------------------------------------------------------------###
##### Variables/Flags
###-------------------------------------------------------------------------###


###-------------------------------------------------------------------------###
##### Firearm functions
###-------------------------------------------------------------------------###

func _ready() -> void:
	super()

## This code is ran only when a corresponding Event is found
func input(event: InputEvent) -> void:
	super(event)

## Only used for "Automatic" firing_mode weapons
func _physics_process(delta: float) -> void:
	super(delta)


## Called when the primary_action button is pressed; fire a 'Fire' "bullet"
func primary_action() -> void:
	super()
	
	
	## Instantiate the Fire first
	var flame_instance: FireBullet = flame_bullet.instantiate()
	
	## The Fire "bullet" is fired from the nozzle Marker3D, that will be our starting point.
	var start_pos: Vector3 = nuzzle.global_position
	#
	## We will use the Viewport's size to get 
	var vp_size: Vector2 = get_viewport().size
	#
	## Again, we use the Camera3D's built-in function to determine the general end point
	## of this "Bullet", which is way off into the distance in the Player's Camera's looking dir.
	## NOTE: 'vp_size * 0.5' because we cast from the middle of the screen
	var end_pos: Vector3 = player_camera.project_position((vp_size * 0.5), max_distance)
	
	## To get the direction, we just get the difference between these two Vector3s
	flame_instance.direction = (end_pos - start_pos)
	## And make sure the Fire is fired from the nuzzle
	flame_instance.global_position = start_pos
	
	get_tree().get_root().add_child(flame_instance)
	print("flame fired")
	
#
## Called when the secondary_action button is pressed
func secondary_action() -> void:
	super()
