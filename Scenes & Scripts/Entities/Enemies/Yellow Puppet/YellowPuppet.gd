extends Enemy

func _ready() -> void:
	super()

func _physics_process(delta: float) -> void:
	super(delta)

func _process(delta: float) -> void:
	super(delta)

func handle_hit(hit_point: Vector3) -> void:
	super(hit_point)
	
	## We want to get the angle between the Enemy origin point,
	## and the hit_point (the point at which the Hurtbox and the Hitobx intersected).
	var self_pos: Vector2 = Vector2(self.position.x, self.position.z)
	var hit_pos: Vector2 = Vector2(hit_point.x, hit_point.z)
	
	## We subtract this value by 90 degress to align it with the Enemy's "front" (negative Z axis),
	## and we add this Enemy's in-level global rotation
	## We get this angle in degrees to make it easier to use
	var angle_to_hit_point = rad_to_deg(self_pos.angle_to_point(hit_pos) \
	- deg_to_rad(-90) + self.global_rotation.y)
	
	
	
	print(angle_to_hit_point)
	
	## Hit from the 45 degrees up front...
	## NOTE: "or" is used, because angle_to_hit_point only goes between 0 and 360 degrees
	## and this if is really [45 - 0, and 0 - 315]
	if angle_to_hit_point <= 45 or angle_to_hit_point >= 315:
		AnimPlayer.play("Hit_front")
	## ...or from the left...
	elif angle_to_hit_point < 315 and angle_to_hit_point > 225:
		AnimPlayer.play("Hit_left")
	## ...or from the back...
	elif angle_to_hit_point <= 225 and angle_to_hit_point >= 135:
		AnimPlayer.play("Hit_back")
	## ...or from the right.
	elif angle_to_hit_point < 135 and angle_to_hit_point > 45:
		AnimPlayer.play("Hit_right")
	
	
	
	
