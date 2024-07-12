class_name PlayerInteractionManager
extends Node


###-------------------------------------------------------------------------###
##### Variables and references
###-------------------------------------------------------------------------###

## Reference to the Player, so its functions and variables can be accessed directly
var player: Player

## All the interactable objects within Player's reach (reach is set by each Interactable separately)
var interactables: Array[Node3D] = []


###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

@export_group("Variables")

## Range of the InteractableCast in meters
@export var InteractableCast_range: float = 1

## The Node from which the ray originates
## Should be the Camera
@export var ray_start_pos_node: Node3D

## Layers which the interaction ray can see, so pretty much just the Interactable layer
## Only made an exported variable to avoid headaches with hard-coded layers
@export_flags_3d_physics var ray_collision_mask = 32

###-------------------------------------------------------------------------###
##### Setup functions
###-------------------------------------------------------------------------###

## This Node needs a reference to the Player to access its functions and variables
func init(player: Player) -> void:
	self.player = player

###-------------------------------------------------------------------------###
##### Executing functions
###-------------------------------------------------------------------------###

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		interact()


## We try to interact with an Interactable node
func interact() -> void:
	## First, check if there are any Interactables within range
	#
	## If not, nothing happens
	if interactables.size() == 0:
		return
	## If there is just one (and the Player is looking at it), we interact with it.
	elif interactables.size() == 1:
		var result: Dictionary = cast_interactable_ray()
		## If there is an Interactable where we're looking,
		if result:
			## We get the interactable_object from the Interactable node
			var interactable_object: Node3D = result.collider.interactable_object
			
			## We call the interactable_object's interact() function directly
			## and it does whatever it wants to do when it's interacted with
			if interactable_object.has_method("interact"):
				interactable_object.interact()
				
				interactable_object
		
		
	## If there is just one (and the Player is looking at it), we interact with it.
	elif interactables.size() >= 2:
		pass




## Create a Ray in Space, which will look for Interactable Area3Ds
func cast_interactable_ray() -> Dictionary:
	## We get the space_state by asking the Player to get it. A Node cannot access it otherwise.
	var space_state: PhysicsDirectSpaceState3D = player.get_world_3d().direct_space_state
	
	## Parameters of the Ray;
	#
	## Starting position of the Ray
	var start_pos: Vector3 = ray_start_pos_node.global_transform.origin
	## End position of the Ray; start_pos extended towards where the Player is looking,
	## multiplied by InteractableCast_range
	var end_pos: Vector3 = start_pos - \
	ray_start_pos_node.global_transform.basis.z * InteractableCast_range
	
	## Set the above Ray parameters
	var ray_param: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(start_pos, \
		end_pos, ray_collision_mask)
	## We want it to detect only areas
	ray_param.collide_with_areas = true
	ray_param.collide_with_bodies = false
	
	## Finally, cast the Ray itself in space_state, with ray_param as its parameters
	return space_state.intersect_ray(ray_param)
