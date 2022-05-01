extends Unit

export var spawn_countdown: int = 2 setget _set_spawn_countdown

func _ready():
  _set_spawn_countdown(spawn_countdown)

func process_turn():
  yield(get_tree(), "idle_frame")
  _set_spawn_countdown(spawn_countdown - 1)

func _set_spawn_countdown(value):
  spawn_countdown = value
  $CountdownTimer.text = "%s" % value
  
  if value <= 0:
    Events.emit_signal("spawner_finished", self)
    queue_free()
