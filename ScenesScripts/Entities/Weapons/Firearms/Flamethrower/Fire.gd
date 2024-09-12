class_name FireBullet
extends RigidBody3D


###-------------------------------------------------------------------------###
##### References
###-------------------------------------------------------------------------###

## Fire's Collider. Gets slightly bigger with range travelled (actually, gets bigger with time),
## because IRL a Flamethrower's flammable liquid spreads as it travells through the air.
@export var collider: CollisionShape3D

## Reference to the Fire's Hitbox. Its own Collider also increases in size with time,
## but it gets way bigger, because IRL the Flames get bigger due to heat and oxygen exposure.
@export var hitbox_collider: CollisionShape3D


###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

## Speed at which this "Bullet" moves through space in direction
@export_range(0.1, 999.0, 0.1) var speed: float = 40.0

## How big should the Flame's Hitbox's Collider be by the time the Flame is at its biggest?
## (in meters)
@export_range(0.1, 999.0, 0.1) var max_hitbox_size: float = 1.8

## How much time must pass until the Flame's Hitbox's Collider is at its biggest?
## (in seconds)
@export_range(0.1, 50.0, 0.1) var time_until_max_hitbox_size: float = 3.5


###-------------------------------------------------------------------------###
##### Regular variables
###-------------------------------------------------------------------------###

## Direction in which this "bullet" will move in over time.
var direction: Vector3


###-------------------------------------------------------------------------###
##### Core functions
###-------------------------------------------------------------------------###

func _ready() -> void:
	## Set this Body's linear velocity to direction set by the Firearm it was fired from.
	## Normalize the direction and make it move at 'speed' velocity.
	linear_velocity = direction.normalized() * speed
	
	## The Fire's Hitbox's and Collider's sizes should increase over time,
	## because IRL fire burns through the fluid and the flames rise with heat;
	## in result, the Flame gets bigger with time.
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self.hitbox_collider.shape, "radius", \
		max_hitbox_size, time_until_max_hitbox_size)
	
