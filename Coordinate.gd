extends Object

class_name Coordinate

var q: int
var r: int

func _init(_q: int = 0, _r: int = 0):
  q = _q
  r = _r

func get_key():
  return str(q, "_", r)
  
func set_from_key(key: String):
  var elements = key.split_floats("_")
  q = elements[0]
  r = elements[1]
  return self

var top = 1000
var bottom = -1000

# For a unique id for path finding
func to_int():
  return (q - bottom) * (top - bottom + 1) + r - bottom

func from_int(id):
  q = floor(id / (top - bottom + 1) + bottom)
  r = id % (top - bottom + 1) + bottom
  return self
