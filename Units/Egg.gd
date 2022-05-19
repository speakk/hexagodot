extends Unit

export var spawn_countdown: int = 1 setget _set_spawn_countdown

var original_scale_y
var time = randf()

const wiggle_amount = 0.07
const offset = 1 - wiggle_amount
const wiggle_speed = 10

func _ready():
  _set_spawn_countdown(spawn_countdown)
  original_scale_y = $Sprite.scale.y

func _process(dt):
  time += dt
  $Sprite.scale.y = original_scale_y * ( sin(time * wiggle_speed) * wiggle_amount) + offset

func process_turn():
  yield(get_tree(), "idle_frame")
  _set_spawn_countdown(spawn_countdown - 1)

func _set_spawn_countdown(value):
  spawn_countdown = value
  $CountdownTimer.text = "%s" % value
  
  if value <= 0:
    Events.emit_signal("spawner_finished", self)
    queue_free()
