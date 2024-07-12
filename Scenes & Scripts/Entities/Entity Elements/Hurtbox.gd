class_name Hurtbox
extends Area3D


## A reference to the Node with a script dedicated to an Entity's stats and DamageData reception
@export var DamageDataReceiver: HurtHandler

## Called by the Hitbox (or something else) to pass on a DamageData Resource,
## which is now passed to the DamageDataReceiver
func pass_DamageData(damageData: DamageData) -> void:
	DamageDataReceiver.receive_DamageData(damageData)
