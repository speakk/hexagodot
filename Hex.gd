extends Node2D

class_name Hex

export var q = 0
export var r = 0

# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.

func init(_q, _r):
  q = _q
  r = _r
  position = MapTools.pointy_hex_to_pixel(Coordinate.new(_q, _r))
  return self
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
