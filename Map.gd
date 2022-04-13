extends YSort

class_name Map

const HEX = preload("Hex.tscn")
const UNIT = preload("Unit.tscn")

# coordinate key -> unit
var unit_map: Dictionary = {}

var hexes: Dictionary = {}

var astar = AStar2D.new()

var hilighted_path

var selected_unit

func _ready():
  var coordinates = MapTools.create_grid(7, MapTools.MapShape.Hexagonal)
  for coordinate in coordinates:
    var hex = HEX.instance().init(coordinate.q, coordinate.r)
    hex.connect("hex_clicked", self, "_on_hex_clicked")
    hex.connect("hex_hovered", self, "_on_hex_hovered")
    add_child(hex)
    hexes[coordinate.to_int()] = hex
    astar.add_point(coordinate.to_int(), MapTools.pointy_hex_to_pixel(coordinate))
  
  for coordinate in coordinates:
    var neighbor_directions = MapTools.get_neighbor_directions()
    for neighbor_direction in neighbor_directions:
      var neighbor_coordinate = MapTools.coordinate_add(coordinate, neighbor_direction)
      if astar.has_point(neighbor_coordinate.to_int()):
        astar.connect_points(coordinate.to_int(), neighbor_coordinate.to_int(), false)

func _process(dt):
  for key in hexes:
    hexes[key].path_hilight = false
    
  if hilighted_path:
    for id in hilighted_path:
      var coordinate = Coordinate.new().from_int(id)
      var hex = hexes[id]
      hex.path_hilight = true
      

func _on_hex_clicked(hex: Hex):
  var coordinate = hex.to_coordinate()
  if unit_map.has(coordinate.get_key()):
    for key in unit_map:
      unit_map[key].deselect()
    select_unit(coordinate)
  else:
    if selected_unit:
      move_unit(selected_unit, coordinate)
    else:
      place_unit(coordinate)
    
func _on_hex_hovered(hex: Hex):
  print("uh...")
  if selected_unit:
    var from_coord
    for key in unit_map:
      if unit_map[key] == selected_unit:
        from_coord = Coordinate.new().set_from_key(key)
        break
        
    hilighted_path = astar.get_id_path(hex.to_coordinate().to_int(), from_coord.to_int())

func place_unit(coordinate: Coordinate):
  var unit = UNIT.instance().init(coordinate.q, coordinate.r)
  unit_map[coordinate.get_key()] = unit
  add_child(unit)

func select_unit(coordinate: Coordinate):
  var unit = unit_map.get(coordinate.get_key())
  unit.select()
  selected_unit = unit
  
func move_unit(unit, to):
  pass
