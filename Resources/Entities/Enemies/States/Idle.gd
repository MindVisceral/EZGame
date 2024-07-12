extends BaseEnemyState

func enter() -> void:
	super.enter()
	enemy.AnimPlayer.play("Idle ") ## Fucked up HERE, should be no space

func exit() -> void:
	super.exit()
	
