extends Node2D

class_name Unit

var team

export var q: int
export var r: int
export var selected: bool = false

func init(_q, _r):
  q = _q
  r = _r
  #MapTools.move_entity_to_coordinate(self, Coordinate.new(_q, _r))
  return self
  
func place(_q, _r):
  q = _q
  r = _r
  
func get_coordinate():
  return Coordinate.new(q, r)

func select():
  selected = true
  $SelectRing.visible = true

func deselect():
  selected = false
  $SelectRing.visible = false
