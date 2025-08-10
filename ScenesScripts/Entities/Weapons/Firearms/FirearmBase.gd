extends Marker3D
class_name FirearmBase
## ^NOTE: This is the Base Firearm Node! ALL the other weapons and weapon classes depend on it!^
## NOTE: This is a WIELDABLE weapon only meant to be handled by the Player!
## NOTE: Enemies get their own weapons, and 'pickupable' weapons are another thing entirely.


###-------------------------------------------------------------------------###
##### Onready variables
###-------------------------------------------------------------------------###

## All weapons need to know the Player
var player: Player

## Attempting to fire the Firearm before the last shot is done (and this Timer is up) does nothing.
@export var ShotCooldownTimer: Timer

## Reference to the Audio Player
@onready var AudioPlayer: AudioStreamPlayer3D = $AudioPlayer

## HERE: Unnecessary?
#
## This node is created Automaticaly when a Model is imported,
## if the model file has animations attached to it. We just need a reference to it with this.
@export var AnimPlayer: AnimationPlayer


###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

@export_group("Weapon parameters")

## Firing mode - whether the primary action button can be held or not.
## Setting this to "Single-shot" forces the Player to click between each shot,
## and setting this to "Automatic" allows the Player to hold the firing button.
@export_enum("Single-shot", "Automatic") var firing_mode: int = 0

## Number of bullets created in a single shot, in ex. shotguns.
@export_range(0, 300, 1) var number_of_bullets: int = 1

## Bullet spread; X is horizontal spread, Y is vertical spread.
## NOTE: Unknown units - just eye it.
@export var bullet_spread: Vector2 = Vector2.ZERO

## Time the weapon waits before the next individual shot can be fired, measured in seconds.
## Attempting to fire before this time is up doesn't do anything.
@export_range(0.01, 3.0, 0.005) var shot_cooldown: float = 0.15

## Default damage done by the Firearm
@export_range(0, 20, 0.25) var default_damage: float = 1

## The maximum distance (in meters) the bullets may travel away from their starting point
## (Used both for Hitscans and Projectiles, but Projectiles must be freed manually, while
## Hitscans just don't work past this value)
@export var max_distance: float = 10000

## Layer on which the bullet :is:; should be the Hitbox layer
#@export_flags_3d_physics var bullet_collision_layer ## HERE - seems unneccessary ## HERE: Why? forgot
## Layers which the bullet can 'see', and therefore damage;
## should be the Hurtbox and Environment layers - to damage Entities and for effects to work.
@export_flags_3d_physics var bullet_collision_mask


###-------------------------------------------------------------------------###
##### Variables/Flags
###-------------------------------------------------------------------------###

## Whether or not the primary fire button is held down. Used for "Automatic" firing_mode weapons.
## Check _physics_process() for usage.
var primary_fire_is_held: bool = false


###-------------------------------------------------------------------------###
##### Firearm functions
###-------------------------------------------------------------------------###

func _ready() -> void:
	## Set ShotCooldownTimer's wait_time.
	ShotCooldownTimer.wait_time = shot_cooldown

## This code is ran only when a corresponding Event is found
func input(event: InputEvent) -> void:
	## primary_action input check
	if Input.is_action_just_pressed("primary_action"):
		## Primary fire button is considered to be held down now.
		## NOTE: This is only used for "Automatic" firing_mode weapons
		primary_fire_is_held = true
		
		## This is a check for "Single-shot" firing_mode weapons
		if firing_mode == 0:
			## If the weapon is ready to fire...
			if ShotCooldownTimer.is_stopped():
				primary_action()
				ShotCooldownTimer.start()
	
	## Primary fire button has been released.
	## NOTE: This is only used for "Automatic" firing_mode weapons
	if Input.is_action_just_released("primary_action"):
		primary_fire_is_held = false
		
	
	## secondary_action input check
	if Input.is_action_just_pressed("secondary_action"):
		secondary_action()
		
	

## Only used for "Automatic" firing_mode weapons
func _physics_process(delta: float) -> void:
	## Having the firing_mode set to "Automatic" requires this code to run in _physics_process()
	if firing_mode == 1:
			## If the weapon is ready to fire...
			if ShotCooldownTimer.is_stopped():
				## If the primary firing button is held down, fire away.
				if primary_fire_is_held == true:
					primary_action()
					ShotCooldownTimer.start()
				
			
		
	


## Called by the WeaponManager when this weapon is meant to be wielded by the Player
func wield_weapon() -> void:
	self.visible = true
#
## Called by the WeaponManager when this weapon is meant to be put away by the Player
func put_weapon_away() -> void:
	self.visible = false
	## Consider the primary_fire button released. The weapon will continue shooting otherwise.
	primary_fire_is_held = false
	


## Called when the primary_action button is pressed
func primary_action() -> void:
	## Play a random firing sound
	AudioPlayer.play()
#
## Called when the secondary_action button is pressed
func secondary_action() -> void:
	pass
