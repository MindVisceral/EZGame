extends ProjectileBase

###-------------------------------------------------------------------------###
##### Core functions
###-------------------------------------------------------------------------###

func _ready() -> void:
	super()
	

## When the Projectile collides with something, it deals damage (if applicable) and gets destroyed.
func _on_collision(body: Node) -> void:
	super(body)
	
