class_name PlayerInteractionManager
extends Node


###-------------------------------------------------------------------------###
##### Variables and references
###-------------------------------------------------------------------------###

## Reference to the Player, so its functions and variables can be accessed directly
var player: Player
## Reference to the Player's Camera. Required for my reimplementation of ray_picking
## (which was neccessary because some twat made MOUSE_MODE_CAPTURED disable ray_picking. Fuck you.)
var camera: Camera3D



## All the Interactable nodes within Player's reach (reach is set in each Interactable separately)
var interactables: Array[Interactable] = []

var currently_focused_on: Interactable

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
	self.camera = player.Camera

###-------------------------------------------------------------------------###
##### Executing functions
###-------------------------------------------------------------------------###

func _unhandled_input(event: InputEvent) -> void:
	## When the Player wants to interact with something...
	if Input.is_action_just_pressed("input_interact"):
		## Fire the InteractableCast, check if it collided with any Interactables
		player.InteractableCast.force_shapecast_update()
		if player.InteractableCast.is_colliding():
			## Now we will find the closest Interactable among the Interactables that
			## the InteractableCast managed to find
			
			## We make a new Array that holds all the Ineractables we will be considering
			var found_interactables: Array
			for found_interactable in player.InteractableCast.collision_result:
				found_interactables.append(found_interactable.collider)
			
			## And we pass that Array to the find_closest_interactable() function, which
			## will find the closest Interactable!
			var closest_interactable = find_closest_interactable(found_interactables)
			
			## Now we simply interact with that closest Interactable
			closest_interactable.interact.emit()



func _process(delta: float) -> void:
	## Maybe this belongs in _physics_process?
	## A reimplementation of ray_picking; used in object highlighting
	var ray_length: float = 1000.0
	
	## We get the mouse position on the screen, which should be right in the middle
	## thanks to MOUSE_MODE_CAPTURED (set in the Player script)
	var mouse_pos = get_viewport().get_mouse_position()
	## We calcualate our ray's start and end postions
	## by projecting from the Camera to some point in the distance
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	
	## Get space_state, cast a Ray
	## MEEELT THE ICEEE, REHEEAAT THE DEEADDDD, TERRAFORM THE PLANET, COMPRESS THE LUUNGSS
	var spaceState = player.get_world_3d().direct_space_state
	var physicsRaycastQuery = PhysicsRayQueryParameters3D.create(from, to, ray_collision_mask)
	## We only check for Interactables, which are areas
	physicsRaycastQuery.collide_with_areas = true
	physicsRaycastQuery.collide_with_bodies = false
	physicsRaycastQuery.hit_from_inside = true
	## We get the result
	var result = spaceState.intersect_ray(physicsRaycastQuery)
	
	## First, we unfocus from the current Interatable, if one was set to be focused previously.
	if currently_focused_on:
		currently_focused_on.unfocused.emit()
	
	## If the result isn't null...
	if result:
		## If the collider is an Interactable node...
		if result.collider is Interactable:
			## We register this Interactable and make it emit the focused signal
			currently_focused_on = result.collider
			currently_focused_on.focused.emit()


## Finds the Interactable which is the nearest to the Player
## (but only if it has been detected by InteractableCast)
func find_closest_interactable(found_interactables_array: Array) -> Interactable:
	
	## INF on our first check in the loop, because there is no bigger distance than that
	var distance_to_interactable = INF
	## I left this at Null, because we know that there is a closest Interactable somewhere,
	## because this function wouldn't be called otherwise.
	var closest_interactable: Interactable
	
	## We loop through all the Interactables that the InteractableCast could find
	## to find the Interactable that is the closest to the Player
	for item in found_interactables_array:
		## We get this Interactable's distance to the Player...
		var new_distance = item.global_position.distance_to(player.global_position)
		## ...and check if this distance is smaller than the last distance...
		if new_distance < distance_to_interactable:
			## If so, we update these two variables
			distance_to_interactable = new_distance
			closest_interactable = item
		
	
	## Now that we are sure which Interactable is the closest, we simply return it
	return closest_interactable
