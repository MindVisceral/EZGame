extends Marker3D
class_name Firearm


###-------------------------------------------------------------------------###
##### Onready variables
###-------------------------------------------------------------------------###

## Needed in all the weapons
var player: Player
## This node is created automaticaly when a Model is imported,
## if the model file has animations attached to it 
@export var AnimPlayer: AnimationPlayer

###-------------------------------------------------------------------------###
##### Variable storage
###-------------------------------------------------------------------------###

@export_group("Weapon parameters")

## The maximum distance the bullets may travel away from their starting point
## (Used both for bullets that are Rays and Projectiles, but those must be destroyed manually)
@export var max_distance: float = 10000
## Layer on which the bullet is; should be the Hitbox layer
@export_flags_3d_physics var bullet_collision_layer
## Layers which the bullet can see; should be the Hurtbox layer
## (in a RayCast weapon, also the Environment)
@export_flags_3d_physics var bullet_collision_mask


## Called by the WeaponManager when this weapon is meant to be wielded/put away by the Player
func wield_weapon() -> void:
	self.visible = true
#
func put_weapon_away() -> void:
	self.visible = false


## Called by the WeaponManager when the primary_action or the secondary_action buttons are pressed
func primary_action() -> void:
	pass
#
func secondary_action() -> void:
	pass
