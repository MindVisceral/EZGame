extends EnemyAIBase


## This Enemy can notice the Player when they enter their EntityDetectionArea.
## When noticed, they will walk up to the Player up to a specified distance and stop to attack.


###-------------------------------------------------------------------------###
##### References
###-------------------------------------------------------------------------###

@export_group("References")

## Reference to the Navigate State. It handles all movement towards the target.
@export var navigate_state: BaseEnemyState

## Reference to the Navigate State. It handles all movement towards the target.
@export var attack_state: BaseEnemyState


###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

@export_group("Exported variables")

## How close this Enemy can get to their target before they stop to attack (in meters)
@export_range(0.01, 100.0, 0.1) var ideal_distance_to_target: float = 3


###-------------------------------------------------------------------------###
##### Functions
###-------------------------------------------------------------------------###

func setup() -> void:
	pass

## Only used to calculate time between AI updates.
func _physics_process(delta: float) -> void:
	## Simple Time.msec clock. Updates AI about every (time_between_AI_updates) milliseconds.
	## Offset by a random number; without this, all Enemies would update their AI on the same frame,
	## which would defeat the whole point of using a clock.
	if (Time.get_ticks_msec() + randi_range(0, 20) - time_at_last_AI_update) >= \
			time_between_AI_updates:
		time_at_last_AI_update = Time.get_ticks_msec()
		
		update_AI()
		
	

## AI is only updated once every few hundred milliseconds for efficiency. It's unnoticable anyway.
func update_AI() -> void:
	## Time debug print
	#print("AI ", self, " updated at ", time_at_last_AI_update,"!")
	
	## Check if the Player is within range of EntityDetectionArea
	var overlaps: Array = enemy.EntityDetectionArea.get_overlapping_bodies()
	## If an overlapping body within EntityDetectionArea is a Player, make them the AI's target.
	for body in overlaps:
		if body is Player:
			enemy.target = body
			## Player is found, no need to loop through this Array anymore.
			#print("Player found, stopping loop")
			break
		## Player not found, target remains null.
		else:
			enemy.target = null
		
	
	
	## If there is a target...
	if enemy.target != null:
		## When not currently attacking...
		if enemy.States.current_state != attack_state:
			## Find a path to the target's position, and Navigate towards it with the nav State
			AI_handler.find_path_to(enemy.target.global_position)
			
			enemy.States.change_state(navigate_state)
			
		## NOTE: ^The path is updated on every AI update^
		
		## This part checks when the Enemy is within range to attack the target
		#
		## Calculate distance.
		var distance_to_target: float = enemy.global_position.distance_to(enemy.target.global_position)
		## Check if the distance is right...
		if distance_to_target <= ideal_distance_to_target:
			
			## Reset pathfinding, it's not needed right now.
			AI_handler.reset_path()
			
			## Now, attack!
			enemy.States.change_state(attack_state)
		
	
