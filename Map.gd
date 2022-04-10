extends YSort

class_name Map

const HEX = preload("Hex.tscn")
const UNIT = preload("Unit.tscn")

var unit_map: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
  var coordinates = MapTools.create_grid(7, MapTools.MapShape.Hexagonal)
  for coordinate in coordinates:
    var hex = HEX.instance().init(coordinate.q, coordinate.r)
    hex.connect("hex_clicked", self, "_on_hex_clicked")
    add_child(hex)

func _on_hex_clicked(hex: Hex):
  print("HEX CLICKED")
  var coordinate = hex.to_coordinate()
  if unit_map.has(coordinate.get_key()):
    for key in unit_map:
      unit_map[key].deselect()
    select_unit(coordinate)
  else:
    place_unit(coordinate)

func place_unit(coordinate: Coordinate):
  var unit = UNIT.instance().init(coordinate.q, coordinate.r)
  unit_map[coordinate.get_key()] = unit
  add_child(unit)

func select_unit(coordinate: Coordinate):
    unit_map.get(coordinate.get_key()).select()
