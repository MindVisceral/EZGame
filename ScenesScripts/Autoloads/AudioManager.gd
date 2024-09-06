extends Node

enum Type {
	NON_POSITIONAL,
	POSITIONAL_3D,
}

## Instantiates an audio_stream_player as child of 'parent' and plays a sound
func play(type: int, parent: Node, sound: AudioStream, \
		volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	
	## This Node will be instantiated
	var audio_stream_player: Node
	
	## We check if audio_stream_player should be a regular StreamPlayer or a StreamPlayer3D
	match type:
		Type.NON_POSITIONAL:
			audio_stream_player = AudioStreamPlayer.new()
		Type.POSITIONAL_3D:
			audio_stream_player = AudioStreamPlayer3D.new()
	
	## We instantiate audio_stream_player
	parent.add_child(audio_stream_player)
	## Then we change its variables
	audio_stream_player.bus = "Sounds"
	audio_stream_player.stream = sound
	audio_stream_player.volume_db = volume_db
	audio_stream_player.pitch_scale = pitch_scale
	## Play the sound and queue_free() it once it's finished
	audio_stream_player.play()
	audio_stream_player.connect("finished", audio_stream_player.queue_free)
