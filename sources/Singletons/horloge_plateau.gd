extends RefCounted
## Horloge monotone de partie, partagée par la sauvegarde, le score et le HUD.
var ticks: Callable = Time.get_ticks_msec
var _started := 0
var _elapsed := 0
var _running := false
var _pauses: Dictionary = {}

func start() -> void:
	_elapsed = 0
	_started = ticks.call()
	_running = true
	_pauses.clear()

func elapsed_ms() -> int:
	return _elapsed + (maxi(0, int(ticks.call()) - _started) if _running and _pauses.is_empty() else 0)

func pause(reason: String, paused: bool) -> void:
	if not _running:
		return
	if paused and not _pauses.has(reason):
		_elapsed = elapsed_ms()
		_pauses[reason] = true
	elif not paused and _pauses.has(reason):
		_pauses.erase(reason)
		if _pauses.is_empty():
			_started = ticks.call()

func stop() -> int:
	_elapsed = elapsed_ms()
	_running = false
	return _elapsed
