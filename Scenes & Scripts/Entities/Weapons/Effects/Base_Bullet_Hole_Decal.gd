extends Decal
## NOTE: This Node is queue_free()-d by the AnimationPlayer when the fade_out animation is finished


## NOTE: This is called by the Node which spawns the Decal!
## NOTE: (that's either the weapon itself or the projectile bullet)
## The first parameter is the position which the bullet hit
## The second parameter is the normal angle at which the Bullet hit
func draw_decal(pos: Vector3, normal: Vector3) -> void:
	## Put the effect at the right global_position where the bullet hit
	self.global_position = pos
	
	## Make the Decal face in the same direction as the hit object's Normals
	self.look_at(self.global_transform.origin + normal, Vector3.UP)
	
	## If the normal isn't pointing directly up or down like it does in the Editor here,
	## in which case the Decal works as intended,
	## then rotate it on the X axis
	if normal != Vector3.UP and normal != Vector3.DOWN:
		self.rotate_object_local(Vector3(1, 0, 0), 90)
	
	## Also, rotate it along the Y axis randomly for a better look.
	self.rotate_object_local(Vector3(0, 1, 0), randf_range(0.0, 360.0))
