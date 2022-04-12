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
  print("set from key", q, r)
  return self

# For a unique id for path finding (+100000 to ensure it's positive)
func to_int():
  return q * 1000 + r + 100000

func from_int(id):
  id = id - 100000
  q = floor(id / 1000)
  r = id - (q * 1000)
  return self
