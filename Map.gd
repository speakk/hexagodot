extends YSort

class_name Map

const HEX = preload("Hex.tscn")
const UNIT = preload("Unit.tscn")

# coordinate key -> unit
var unit_map: Dictionary = {}

var hexes: Dictionary = {}

var astar = AStar2D.new()

var hilighted_path

# Called when the node enters the scene tree for the first time.
func _ready():
  var coordinates = MapTools.create_grid(7, MapTools.MapShape.Hexagonal)
  for coordinate in coordinates:
    var hex = HEX.instance().init(coordinate.q, coordinate.r)
    hex.connect("hex_clicked", self, "_on_hex_clicked")
    hex.connect("hex_hovered", self, "_on_hex_hovered")
    add_child(hex)
    hexes[coordinate.to_int()] = hex
    if hex.q == 0 and hex.r == -3:
      print("WE HAD 0, -3: ", coordinate.to_int())
    astar.add_point(coordinate.to_int(), MapTools.pointy_hex_to_pixel(coordinate))
    if hex.q == 0 and hex.r == -3:
      print("SO NOW HAS POINT RIGHT?", astar.has_point(coordinate.to_int()))    
    #astar.add_point(coordinate.to_int(), hex.position)
  
  for coordinate in coordinates:
    var neighbor_directions = MapTools.get_neighbor_directions()
    if coordinate.q == 0 and coordinate.r == -2:
      print("Okay, 0 and - 2 here...")
      print("Neighbors how many: ", neighbor_directions.size())
    for neighbor_direction in neighbor_directions:
      var neighbor_coordinate = MapTools.coordinate_add(coordinate, neighbor_direction)
      if coordinate.q == 0 and coordinate.r == -2:
        print("Neighbor: ", neighbor_coordinate.q, ", ", neighbor_coordinate.r, " int id: ", neighbor_coordinate.to_int())
      if astar.has_point(neighbor_coordinate.to_int()):
        if coordinate.q == 0 and coordinate.r == -2:
          print("Connecting ", coordinate.q, ",", coordinate.r, " to ", neighbor_coordinate.q, ",", neighbor_coordinate.r)
        astar.connect_points(coordinate.to_int(), neighbor_coordinate.to_int(), false)

func _process(dt):
  for key in hexes:
    hexes[key].path_hilight = false
    
  if hilighted_path:
    for id in hilighted_path:
      var coordinate = Coordinate.new().from_int(id)
      var hex = hexes[id]
      hex.path_hilight = true
      #hex.modulate = Color(0, 1, 0)
      

func _on_hex_clicked(hex: Hex):
  print("HEX CLICKED")
  var coordinate = hex.to_coordinate()
  if unit_map.has(coordinate.get_key()):
    for key in unit_map:
      unit_map[key].deselect()
    select_unit(coordinate)
  else:
    place_unit(coordinate)
    
func _on_hex_hovered(hex: Hex):
  var selected
  var from_coord
  for key in unit_map:
    print("Units key", key)
    if unit_map[key].selected:
      selected = unit_map[key]
      from_coord = Coordinate.new().set_from_key(key)
      break
  
  if selected:
    hilighted_path = astar.get_id_path(hex.to_coordinate().to_int(), from_coord.to_int())
    print("found", " ", hex.to_coordinate().to_int(), " ", from_coord.to_int(), " ", hilighted_path)
    print("So basically ", hex.q, ",", hex.r, " from ", from_coord.q, ",", from_coord.r)
    print("Points connected? ", astar.are_points_connected(hex.to_coordinate().to_int(), from_coord.to_int()))
    

func place_unit(coordinate: Coordinate):
  var unit = UNIT.instance().init(coordinate.q, coordinate.r)
  unit_map[coordinate.get_key()] = unit
  add_child(unit)

func select_unit(coordinate: Coordinate):
    unit_map.get(coordinate.get_key()).select()
