extends Node

# don't forget to use stretch mode 'viewport' and aspect 'ignore'
#onready var viewport = get_viewport()
#var scene_viewport
#onready var viewport = get_viewport()

func _ready():
  get_tree().connect("screen_resized", self, "_screen_resized")

func _resize_viewport(the_viewport: Viewport):
  var window_size = OS.get_window_size()

  # see how big the window is compared to the viewport size
  # floor it so we only get round numbers (0, 1, 2, 3 ...)
  var scale_x = floor(window_size.x / the_viewport.size.x)
  var scale_y = floor(window_size.y / the_viewport.size.y)

  # use the smaller scale with 1x minimum scale
  var scale = max(1, min(scale_x, scale_y))

  # find the coordinate we will use to center the viewport inside the window
  var diff = window_size - (the_viewport.size * scale)
  var diffhalf = (diff * 0.5).floor()

  # attach the viewport to the rect we calculated
  the_viewport.set_attach_to_screen_rect(Rect2(diffhalf, the_viewport.size * scale))

func _screen_resized():
  _resize_viewport(get_viewport())
 # _resize_viewport(SceneManager.get_current_viewport())
