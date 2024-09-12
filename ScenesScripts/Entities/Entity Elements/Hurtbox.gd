class_name Hurtbox
extends Area3D


## A reference to the Node with a script dedicated to an Entity's stats and DamageData reception
@export var Entity: EnemyBase

## Called by the Hitbox (or whatever else) to pass on a DamageData Resource,
## which is now passed to the Entity which can handle it
func pass_DamageData(damageData: DamageData) -> void:
	Entity.receive_DamageData(damageData)
	
