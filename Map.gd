extends YSort

class_name Map

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const HEX = preload("Hex.tscn")
# const Coordinate = preload("Coordinate.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
  var coordinates = MapTools.create_grid(7, MapTools.MapShape.Hexagonal)
  for coordinate in coordinates:
    var hex = HEX.instance().init(coordinate.q, coordinate.r)
    add_child(hex)
