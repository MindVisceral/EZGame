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
@export var nozzle: Marker3D

## Reference to the 'Flames' Node. This is turned on when the Player turns on their Flamethrower.
@export var nozzle_flame: NozzleFlame


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
## Only used for "Automatic" firing_mode weapons
func _physics_process(delta: float) -> void:
	
	## Mostly copied over from FirearmBase!
	#
	## Having the firing_mode set to "Automatic" requires this code to run in _physics_process()
	if firing_mode == 1:
			## If the weapon is ready to fire...
			if ShotCooldownTimer.is_stopped():
				## If the primary firing button is held down, fire away.
				if primary_fire_is_held == true:
					## Enable Flames coming out of the Nozzle
					nozzle_flame.turn_flames_on()
					
					primary_action()
					ShotCooldownTimer.start()
					
				
				## Disable Flames coming out of the Nozzle
				else:
					nozzle_flame.turn_flames_off()
				
			
		
	


## Called when the primary_action button is pressed; fire a 'Fire' "bullet"
func primary_action() -> void:
	super()
	
	## Instantiate the Fire first
	var flame_instance: FireBullet = flame_bullet.instantiate()
	
	## The Fire "bullet" is fired from the nozzle Marker3D, that will be our starting point.
	var start_pos: Vector3 = nozzle.global_position
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
	## And make sure the Fire is fired from the nozzle
	flame_instance.global_position = start_pos
	
	get_tree().get_root().add_child(flame_instance)
	
#
## Called when the secondary_action button is pressed
func secondary_action() -> void:
	super()
