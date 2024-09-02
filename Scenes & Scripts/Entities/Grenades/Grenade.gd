extends RigidBody3D

const GRENADE_DAMAGE = 60

const GRENADE_TIME = 2
var grenade_timer = 0

const EXPLOSION_WAIT_TIME = 0.48
var explosion_wait_timer = 0

var rigid_shape
var grenade_mesh
var blast_area
var explosion_particles

var simple_audio_player = preload("res://Resources/Audio/Simple_Audio_Player.tscn")

func _ready():
	rigid_shape = $Collision_Shape
	grenade_mesh = $Grenade
	blast_area = $Blast_Area
	explosion_particles = $Explosion

	explosion_particles.emitting = false
	explosion_particles.one_shot = true

func _process(delta: float):

	if grenade_timer < GRENADE_TIME:
		grenade_timer += delta
		return
	else:
		if explosion_wait_timer <= 0:
			explosion_particles.emitting = true

			grenade_mesh.visible = false
			rigid_shape.disabled = true

			mode = RigidBody3D.FREEZE_MODE_STATIC

			var bodies = blast_area.get_overlapping_bodies()
			for body in bodies:
				if body.has_method("bullet_hit"):
					body.bullet_hit(GRENADE_DAMAGE, body.global_transform.looking_at(global_transform.origin, Vector3(0, 1, 0)))

			


		if explosion_wait_timer < EXPLOSION_WAIT_TIME:
			explosion_wait_timer += delta
			
			if explosion_wait_timer >= EXPLOSION_WAIT_TIME:
				queue_free()
###
func create_sound(sound_name, position=null):
	var audio_clone = simple_audio_player.instantiate()
	var scene_root = get_tree().root.get_children()[0]
	scene_root.add_child(audio_clone)
	audio_clone.play_sound(sound_name, position)
