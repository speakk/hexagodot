extends Node2D

export var q: int
export var r: int
export var selected: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#  pass

func init(_q, _r):
  q = _q
  r = _r
  MapTools.move_entity_to_coordinate(self, Coordinate.new(_q, _r))
  return self

func select():
  selected = true
  $SelectRing.visible = true

func deselect():
  selected = false
  $SelectRing.visible = false
