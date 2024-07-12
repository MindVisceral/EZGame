extends HitPointHandler
## ^NOTE: This extendes the generic HitPointHandler script^


###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

@export_group("Exported")

###-------------------------------------------------------------------------###
##### Regular variables
###-------------------------------------------------------------------------###


###-------------------------------------------------------------------------###
##### Functions
###-------------------------------------------------------------------------###


## This Node needs a reference to the enemy to access its functions and variables
func init(enemy: EnemyBase) -> void:
	self.enemy = enemy


## Get the point at which YP has been hit, determine the direction of the hit in relation
## to the origin point. With that information, play the corresponding animation.
func handle_hit_point(hit_point) -> void:
	
	
	## We want to get the angle between the Enemy origin point,
	## and the hit_point (the point at which the Hurtbox and the Hitobx intersected).
	var self_pos: Vector2 = Vector2(enemy.position.x, enemy.position.z)
	var hit_pos: Vector2 = Vector2(hit_point.x, hit_point.z)
	
	## We subtract this value by 90 degress to align it with the Enemy's "front" (negative Z axis),
	## and we add this Enemy's in-level global rotation
	## We get this angle in degrees to make it easier to use
	var angle_to_hit_point = rad_to_deg(self_pos.angle_to_point(hit_pos) \
	- deg_to_rad(-90) + enemy.global_rotation.y)
	
	
	## First we stop the current Animation, because we want the animation to start immediately
	enemy.AnimPlayer.stop()
	
	## Hit from the 45 degrees up front...
	## NOTE: "or" is used, because angle_to_hit_point only goes between 0 and 360 degrees
	## and this "if" really goes [45 - 0, and 0 - 315]
	if angle_to_hit_point <= 45 or angle_to_hit_point >= 315:
		enemy.AnimPlayer.play("Hit_front")
	## ...or from the left...
	elif angle_to_hit_point < 315 and angle_to_hit_point > 225:
		enemy.AnimPlayer.play("Hit_left")
	## ...or from the back...
	elif angle_to_hit_point <= 225 and angle_to_hit_point >= 135:
		enemy.AnimPlayer.play("Hit_back")
	## ...or from the right.
	elif angle_to_hit_point < 135 and angle_to_hit_point > 45:
		enemy.AnimPlayer.play("Hit_right")
	
	## Add the Idle animation to the queue, because otherwise no animation at all will play
	enemy.AnimPlayer.queue("Idle ")
