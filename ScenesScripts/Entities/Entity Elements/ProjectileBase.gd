class_name ProjectileBase
extends RigidBody3D


###-------------------------------------------------------------------------###
##### Exported references
###-------------------------------------------------------------------------###

@export_group("Exported references")


###-------------------------------------------------------------------------###
##### References
###-------------------------------------------------------------------------###

@export_group("References")

## Projectile's Collider
@export var collider: CollisionShape3D

## Reference to the Projectile's Hitbox
@export var hitbox_collider: CollisionShape3D


###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

@export_group("Projectile movement variables")

## Speed at which this Projectile moves through space in direction
@export_range(0.1, 999.0, 0.1) var speed: float = 40.0


###-------------------------------------------------------------------------###
##### Regular variables
###-------------------------------------------------------------------------###

## Direction in which this Projectile" will move in
var direction: Vector3


###-------------------------------------------------------------------------###
##### Core functions
###-------------------------------------------------------------------------###

func _ready() -> void:
	## Set this Body's linear velocity to it's movement direction
	## Normalize the direction and make it move at 'speed' velocity.
	linear_velocity = direction.normalized() * speed
	

## When the Projectile collides with something, it's destroyed by default
func _on_collision(body: Node) -> void:
	queue_free()
