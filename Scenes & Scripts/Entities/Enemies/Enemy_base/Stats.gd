class_name Stats
extends Node



###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

@export_group("Exported Variables")

## Self-explainatory
@export_range(0.5, 50) var default_health: float = 1
@export var max_health: float = 20




###-------------------------------------------------------------------------###
##### Regular variables
###-------------------------------------------------------------------------###

## Reference to the Enemy so that their functions and variables can be accessed directly
var enemy: Enemy

## Self-explainatory
var current_health: float = 1.0





###-------------------------------------------------------------------------###
##### Functions
###-------------------------------------------------------------------------###

func _ready() -> void:
	## Set current_health to default_health and clamp it to the maximum of max_health
	current_health = default_health
	current_health = clampf(current_health, -INF, max_health)

## The Stats Node needs a reference to the enemy to access its functions and variables
func init(enemy: Enemy) -> void:
	self.enemy = enemy


## Receive the DamageData Resource and use its values
func receive_DamageData(damageData: DamageData) -> void:
	lower_health(damageData.damage_value)

## Lower Entity's current_health by the provided damage value
func lower_health(damage_value) -> void:
	current_health -= damage_value
	print(enemy, "'s current_health = ", current_health)
	
	## Health is too low, time to die
	if current_health <= 0:
		enemy.death()
