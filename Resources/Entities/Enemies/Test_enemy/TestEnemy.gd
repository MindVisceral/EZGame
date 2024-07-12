extends CharacterBody3D

enum {
	IDLE,
	WALK,
	ATTACK1,
	PURSUE,
}

const PLAYER_HEIGHT = 3
const ATTACK_DAMAGE = 30
const MAX_HEALTH = 16
var health

@onready var AnimPlayer = $AnimationPlayer

@onready var RayCollide = $RayCast3D

@onready var SightFOV = $SightFOV
@onready var SightFOVShape = $SightFOV/FOVShape

@onready var SpotFOV = $SpotFOV
@onready var SpotFOVShape = $SpotFOV/FOVShape

@onready var HitArea = $HitArea
@onready var HitShape = $HitArea/HitShape

@onready var DetectArea = $DetectArea
@onready var DetectShape = $DetectArea/DetectShape

@export var time_between_attacks = 100


#navigation and movement
var speed = 30
@onready var nav = $"../Navigation" as Navigation
@onready var player = $"../../Player" as CharacterBody3D
var path = []
var current_node = 0

var state = IDLE
var is_pursuiting_target: bool = false
@onready var current_target = player


#
func _ready():
	health = MAX_HEALTH
#

#
func _physics_process(delta):
	if is_pursuiting_target == true:
		path_towards_player(delta)
	
	if health <= 0:
		queue_free()
#

#
func _process(delta):
	match state:
		IDLE:
			AnimPlayer.play("Idle")
			is_pursuiting_target = false
			
		WALK:
			AnimPlayer.play("Walk")
			
		ATTACK1:
			AnimPlayer.play("Attack")
			
		PURSUE:
			AnimPlayer.play("Walk")
			SightFOV.look_at(current_target.global_transform.origin + Vector3(0, 0, 0), Vector3(0, 1, 0))
			self.look_at(current_target.global_transform.origin, Vector3(0, 1, 0))
			is_pursuiting_target = true
#

#makes a path towards the current target, makes the enemy move towards that pos
#only works when the current state is PURSUE
func path_towards_player(delta):
	print(path.size())
	
	#we can't just use speed, because the movement is sporadic
	#so we multiply it by delta
	var step_size = delta * speed
	
	if current_node < path.size():
		var dir: Vector3 = path[current_node] - global_transform.origin
		if dir.length() < step_size:
			current_node = step_size
			path.remove(0)
		else:
			set_velocity(dir.normalized() * speed)
			move_and_slide()

#updates ^the path^ needed to move towards the target
func update_path(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos)
#

#when the timer is out, update path
func _on_PathTimer_timeout():
	update_path(current_target.global_transform.origin)
#

#if Player is in the SightFOV shape, changes the state to PURSUE
func _on_SightFOV_body_entered(body):
	if body.is_in_group("Player"):
		current_target = body
		state = PURSUE
#
func _on_SpotFOV_body_exited(body):
	if body.is_in_group("Player"):
		current_target = self
		state = IDLE
#

#
func _on_DetectArea_body_entered(body):
	if body.is_in_group("Player"):
		state = ATTACK1
#
func _on_DetectArea_body_exited(body):
	if body.is_in_group("Player"):
		state = PURSUE
#

#if during the Attack animation (which enables this HitArea's HitShape), 
#a body enters the HitShape and it's the player, cause damage...
func _on_HitArea_body_entered(body):
	if body.is_in_group("Player"):
		attack_connected(body)
#↓this could be put in the above function, but it's here↓
#↓in case it needs to be used again↓
func attack_connected(body):
	if body.has_method("attack_hit"):
			body.attack_hit(ATTACK_DAMAGE)
#

#
func bullet_hit(damage, bullet_hit_pos):
	health -= damage
#
func attack_hit(damage):
	health -= damage
#
