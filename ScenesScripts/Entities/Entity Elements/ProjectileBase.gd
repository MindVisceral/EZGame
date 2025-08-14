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

## Reference to detection Timer
@export var instancer_detection_timer: Timer


###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

@export_group("Projectile movement variables")

## Speed at which this Projectile moves through space in direction
@export_range(0.1, 999.0, 0.1) var speed: float = 10.0


###-------------------------------------------------------------------------###
##### Regular variables
###-------------------------------------------------------------------------###

## Whatever fired this Projectile
var firing_agent: Node3D

## Direction in which this Projectile will move in
var direction: Vector3


###-------------------------------------------------------------------------###
##### Core functions
###-------------------------------------------------------------------------###

func _ready() -> void:
	## Some projectiles may want to ignore their firing_agent - used by default too
	instancer_detection_timer.start()
	
	## Set this Body's linear velocity to it's movement direction
	## Normalize the direction and make it move at 'speed' velocity.
	linear_velocity = direction.normalized() * speed
	
	## Rotate the projectile in the direction of its movement
	self.look_at(transform.origin + direction)

## By default, when the Projectile collides with something it is destroyed
func _on_collision(body: Node) -> void:
	## Whatever fired this Projectile will be ignored for the first few moments of it being fired
	if (instancer_detection_timer.time_left > 0) and (body == firing_agent):
		pass
	
	queue_free()
