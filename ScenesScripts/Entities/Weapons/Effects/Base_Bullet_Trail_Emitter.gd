extends Node3D
## NOTE: This Node is queue_free()-d by the AnimationPlayer when the Trail animation is finished

## This Mesh is the heart of the Trail;
## we simply increase its height and animate it to create a cool effect
## NOTE: Its shader, especially transparency, does most of the heavy lifting
@onready var TrailMesh: MeshInstance3D = $Mesh

## NOTE: This is called by the Node which spawns the TrailEmitter!
## The first parameter is, typically, the gun's barrel; the Trail originates here
## The second parameter is, typically, position which the RayCast bullet hit; the Trail ends here
func draw_mesh(start_pos: Vector3, end_pos: Vector3) -> void:
	## Put the whole TrailEmitter at the start_pos; it will originate from this point in the world
	self.global_position = start_pos
	## Make the whole TrailEmitter rotate towards the end_pos
	## NOTE: The Mesh is already rotated on the X axis to make it point the right way!
	self.look_at(end_pos, Vector3.UP)
	
	## We make the Mesh just the right height to fit between the start and end positions
	TrailMesh.mesh.height = start_pos.distance_to(end_pos)
	## We also have to move it to the halfway point. Otherwise it wouldn't reach the end_pos.
	TrailMesh.position.z -= start_pos.distance_to(end_pos) / 2
	
