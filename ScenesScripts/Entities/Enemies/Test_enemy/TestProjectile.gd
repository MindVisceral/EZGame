extends ProjectileBase

###-------------------------------------------------------------------------###
##### Core functions
###-------------------------------------------------------------------------###

func _ready() -> void:
	super()
	

## When the Projectile collides with something, it deals damage (if applicable) and gets destroyed.
func _on_collision(body: Node) -> void:
	## Whatever fired this Projectile will be ignored for the first few moments of it being fired
	if (instancer_detection_timer.time_left > 0) and (body == firing_agent):
		pass
	
	
	queue_free()
