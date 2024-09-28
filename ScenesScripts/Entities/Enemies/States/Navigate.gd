extends BaseEnemyState

func enter() -> void:
	super.enter()
	#enemy.AnimPlayer.play("Idle ") ## Fucked up HERE, should be no space
	

func exit() -> void:
	super.exit()


func physics_process(delta: float) -> BaseEnemyState:
	
	## Set next destination's position on the Path to the final Target
	var destination = enemy.Navigation.get_next_path_position()
	## Get the destination's position in local space?????
	var local_destination = destination - enemy.global_position
	
	## Get direction. You get what it is already.
	var direction = local_destination.normalized()
	
	## Make the Enemy move towards their destination. move_and_slide handled delta already...
	enemy.velocity = direction * enemy.speed
	
	## Apply gravity (which is the Globals' gravity * multiplier)
	enemy.velocity.y -= enemy.gravity * BulletTime.time_scale * delta
	
	return null
	
	
	
	### Set next destination's position on the Path to the final Target
	#var destination = enemy.Navigation.get_next_path_position()
	### Get the destination's position in local space?????
	#var local_destination = destination - enemy.global_position
	#
	### Get direction. You get what it is already.
	#var direction = local_destination.normalized()
	#
	### Make the Enemy move towards their destination. move_and_slide handled delta already...
	#enemy.velocity = direction * enemy.speed
	#
	### Apply gravity (which is the Globals' gravity * multiplier)
	#enemy.velocity.y -= enemy.gravity * BulletTime.time_scale * delta
