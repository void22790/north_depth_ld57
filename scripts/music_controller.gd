extends Node

@onready var timer: Timer = $Timer
@onready var music: AudioStreamPlayer2D = $Music

var music_tracks: Array = []
var is_music_playing: bool = false

func _ready() -> void:
	music_tracks = [
		preload("res://music/coal.ogg"),
		preload("res://music/ice.ogg"),
		preload("res://music/iron.ogg")
	]
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	timer.start(30)

func _on_timer_timeout() -> void:
	if not is_music_playing:
		var chance = randf_range(0.0, 1.0)
		if chance < 0.4:
			play_random_music()

func play_random_music() -> void:
	var track = music_tracks[randi_range(0, music_tracks.size() - 1)]
	music.stream = track
	music.play()
	is_music_playing = true
	music.connect("finished", Callable(self, "_on_music_finished"))

func _on_music_finished() -> void:
	is_music_playing = false
	music.disconnect("finished", Callable(self, "_on_music_finished"))
