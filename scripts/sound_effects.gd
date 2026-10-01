class_name SoundEffects
extends Node

const MIX_RATE: float = 22050.0
const BUFFER_LENGTH: float = 0.5

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer


func _ready() -> void:
	var generator := AudioStreamGenerator.new()
	generator.mix_rate = MIX_RATE
	generator.buffer_length = BUFFER_LENGTH
	audio_player.stream = generator


func play_shot() -> void:
	_play_tone(720.0, 0.035, 0.05)


func play_enemy_defeated() -> void:
	_play_tone(280.0, 0.1, 0.11)


func play_player_hit() -> void:
	_play_tone(130.0, 0.14, 0.14)


func play_level_up() -> void:
	_play_tone(880.0, 0.18, 0.12)


func play_game_over() -> void:
	_play_tone(95.0, 0.4, 0.16)


func play_game_clear() -> void:
	_play_tone(1040.0, 0.4, 0.14)


func _play_tone(frequency: float, duration: float, volume: float) -> void:
	audio_player.stop()
	audio_player.play()

	var playback := audio_player.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback == null:
		return

	var frame_count := floori(duration * MIX_RATE)
	for frame in frame_count:
		var progress := float(frame) / float(frame_count)
		var envelope := 1.0 - progress
		var sample := sin(TAU * frequency * float(frame) / MIX_RATE) * volume * envelope
		playback.push_frame(Vector2(sample, sample))
