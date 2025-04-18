extends RigidBody3D

const BASE_BULLET_BOOST = 9

func _ready():
	pass

func bullet_hit(damage, bullet_global_trans):
	var direction_vect = bullet_global_trans.basis.z.normalized() * BASE_BULLET_BOOST

	apply_impulse(direction_vect * damage, (bullet_global_trans.origin - global_transform.origin).normalized())
