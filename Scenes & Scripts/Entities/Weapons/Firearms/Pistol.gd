extends Firearm
## ^NOTE: Extends Firearm! Check that scene/script for more if you can't find something here!^


###-------------------------------------------------------------------------###
##### Onready variables
###-------------------------------------------------------------------------###

## The Node from which the bullets originate
## NOTE: If the bullets are Rays, not projectiles, like in this script, this should be the FP Camera
@export var bullet_start_pos_node: Node3D

## The point from which a bullet Trail, and only the Trail, will start
@onready var bullet_start_point: Marker3D = $ModelHolder/gun1/Armature/Base_bone/Grip1/TrailSpawnPoint
## This Node creates a Trail effect, we just instantiate it
@onready var bullet_trail_emitter: PackedScene = \
	preload("res://Scenes & Scripts/Entities/Weapons/Effects/Bullet_Trail_Emitter.tscn")
## This Node creates the Hit Effect, we just instantiate it
@onready var hit_effect_emitter: PackedScene = \
	preload("res://Scenes & Scripts/Entities/Weapons/Effects/Hit_Effect_Emitter.tscn")



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
	
	## Primary action creates a RayCast "bullet"
	cast_bullet_ray()
#
func secondary_action() -> void:
	super.secondary_action()



## HERE - Could be made into bullet holes. LATER [?]
var decal_insta = preload("res://test_decal.tscn")


## Create a Ray in Space, which will act as a bullet for this RayCast-type weapon
func cast_bullet_ray() -> void:
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	
	## Parameters of the Ray;
	#
	## Starting position of the Ray, the point from which the bullets will come out of
	var start_pos: Vector3 = bullet_start_pos_node.global_transform.origin
	## End pos of the Ray; start_pos extended towards where the Player is looking,
	## multiplied by the weapon's @export-ed max_distance variable
	var end_pos: Vector3 = start_pos - bullet_start_pos_node.global_transform.basis.z * self.max_distance
	#
	## bullet_collision_mask is @export-ed from the Firearm script; change it in the editor
	## the RayCast only detects objects with on this variable
	
	## Set the above Ray parameters
	var ray_param: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(start_pos, \
		end_pos, bullet_collision_mask)
	## We want it to detect HurtBoxes (which are Areas) too, not just bodies
	ray_param.collide_with_areas = true
	## Finally, cast the Ray itself in space_state, with ray_param as its parameters
	var result: Dictionary = space_state.intersect_ray(ray_param)
	
	
	## Now we check results of this cast Ray
	## TODO HERE - do damage calcualtions, then hitting the environment, then not hitting anything
	
	## Doesn't matter if the "Bullet" hits anything, we always instantiate a Trail anyway
	## BUT passing parameters to the Trail function requires getting hit info
	## (or the lack of it) - that part is below
	var trail = bullet_trail_emitter.instantiate()
	get_tree().get_root().add_child(trail)
	
	
	## The "Bullet" hit something. We need hit info to instantiate the Trail and the Hit Effect
	if result:
		
		## If the Ray-hit Node is a Hurtbox, we can pass weapon-specific damage values to it!
		if result.collider is Hurtbox:
			## Create a new DamageData Resource, which the Hurtbox will interpret
			## and pass on to the Enemy
			var damageData = DamageData.new()
			
			## We give this Resource some data of this weapon
			damageData.damage_value = default_damage
			
			## With DamageData's data assigned,
			## we pass this Resource on to the result.collider's Hurtbox
			result.collider.pass_DamageData(damageData)
		
		
		
		
		
		
		
		## Instantiate a test decal
		var decal = decal_insta.instantiate()
		get_tree().get_root().add_child(decal)
		## Put it where it should be
		decal.position = result.position
		
		## Instantiate a Hit Effect
		var hit_effect = hit_effect_emitter.instantiate()
		get_tree().get_root().add_child(hit_effect)
		## The first parameter is the point at which the Hit Effect is emitted,
		## the second one is the result's normal;
		## we use it to make the Particles emit at the proper angle to the hit object
		hit_effect.draw_effect(result.position, result.normal)
		
		## The first parameter is the point at which the Trail starts,
		## the second one is where the Trail ends
		trail.draw_mesh(bullet_start_point.global_position, result.position)
		
	## The Bullet hasn't hit anything. We only instantiate the Trail
	else:
		## The second parameter is just a Vector3 somewhere way off in the distance
		## to create an illusion that the bullet goes on beyond where the Player can see
		trail.draw_mesh(bullet_start_point.global_position, end_pos)
