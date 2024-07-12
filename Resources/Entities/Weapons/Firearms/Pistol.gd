extends Firearm
## ^NOTE: Extends Firearm! Check that scene/script for more information if you can't find it here!^


###-------------------------------------------------------------------------###
##### Onready variables
###-------------------------------------------------------------------------###

## The Node from which the bullets originate
## NOTE: If the bullets are Rays, not projectiles, like in this script, this should be the FP Camera
@export var bullet_start_pos_node: Node3D

## The point from which a bullet Trail, and only the Trail, will start
@onready var bullet_start_point: Marker3D = $ModelHolder/gun1/Armature/Base_bone/Grip1/TrailSpawnPoint
## This Node create a Trail effect, we just instantiate it
@onready var bullet_trail_emitter: PackedScene = \
	preload("res://Resources/Entities/Weapons/Bullet_Trail_Emitter.tscn")



###-------------------------------------------------------------------------###
##### Variable storage
###-------------------------------------------------------------------------###





## Called by the WeaponManager when this weapon is meant to be wielded/put away by the Player
func wield_weapon() -> void:
	super.wield_weapon()
#
func put_weapon_away() -> void:
	super.put_weapon_away()


## Called by the WeaponManager when the primary_action or the secondary_action buttons are pressed
func primary_action() -> void:
	super.primary_action()
	
	## Create a "bullet"
	cast_bullet_ray()
#
func secondary_action() -> void:
	super.secondary_action()



## HERE - Could be made into bullet holes. LATER [?]
var decal_insta = preload("res://test_decal.tscn")
@onready var hit_effect = preload("res://Resources/Entities/Weapons/Effects/Hit_Effect.tscn")

## Create a Ray in Space, which will act as a bullet for this RayCast-type weapon
func cast_bullet_ray() -> void:
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	
	## Parameters of the Ray;
	#
	## Starting position of the Ray, the point from which the bullets will come out of
	var start_pos: Vector3 = bullet_start_pos_node.global_transform.origin
	## End pos of the Ray; start_pos extended towards where the Player is looking,
	## multiplied by the weapon's exported max_distance variable
	var end_pos: Vector3 = start_pos - bullet_start_pos_node.global_transform.basis.z * self.max_distance
	#
	## bullet_collision_layer is @exported; it's set in editor. It's in the Firearm script
	
	## Set Ray parameters; they are above this comment
	var ray_param: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(start_pos, \
		end_pos, self.bullet_collision_layer)
	## Cast the Ray itself in space_state, with ray_param as its parameters
	var result: Dictionary = space_state.intersect_ray(ray_param)
	
	
	
	
	
	
	
	## Check results
	## TODO HERE - do damage calcualtions, then hitting the environment, then not hitting anything
	
	
	
	
	if result:
#		print(result)
		## Test decal to check for collision
		var decal = decal_insta.instantiate()
		get_tree().get_root().add_child(decal)
		decal.position = result.position
		
	else:
		print("shot nothing!")
	
	
	## Either way, instantiate a trail
	var trail = bullet_trail_emitter.instantiate()
	get_tree().get_root().add_child(trail)
	## The first parameter is the point at which the Trail will start,
	## the second one is where the Trail ends
	if result:
		trail.draw_mesh(bullet_start_point.global_position, result.position)
		
		
		##
		var hiteffect = hit_effect.instantiate()
		get_tree().get_root().add_child(hiteffect)
		hiteffect.draw_effect(result.position, result.normal)
		
	else:
		trail.draw_mesh(bullet_start_point.global_position, end_pos)
	
