class_name MapTools

const HEX_SIZE: float = (32.0 / 2.0) * 1.1
const HEX_LAYOUT_SIZE_X: float = HEX_SIZE
const HEX_LAYOUT_SIZE_Y: float = HEX_SIZE * 1.2


const POINTY_HEX_MATRIX = {
  f0 = sqrt(3),
  f1 = sqrt(3) / 2,
  f2 = 0,
  f3 = 3 / 2,
  b0 = sqrt(3) / 3,
  b1 = -1 / 3,
  b2 = 0,
  b3 = 2 /3
}

enum MapShape {
    Hexagonal,
    Square
}

static func generate_terrain(hexes):
  var noise = OpenSimplexNoise.new()
  noise.seed = randi()
  noise.octaves = 2
  noise.period = 3
  noise.persistence = 0.5
  
  for hex in hexes:
    var value = noise.get_noise_2d(hex.q, hex.r)
    var type = TerrainDB.TerrainType.Dirt
    if value > 0:
      type = TerrainDB.TerrainType.Grass
    
    if value > 0.4:
      type = TerrainDB.TerrainType.Water
    elif noise.get_noise_2d(hex.q + 1, hex.r + 1) > 0.3:
      #type = TerrainDB.TerrainType.Mountain
      hex.raised = true
    
    hex.terrain_type = type

static func create_grid(radius: int, shape) -> Array:
    var hexes: Array = []

    if shape == MapShape.Hexagonal:
      for q in range(-radius, radius):
                var r1: int = int(max(-radius, -q - radius))
                var r2: int = int(min(radius, -q + radius))

                for r in range(r1,r2):
                    hexes.push_back(HexPrototype.new(q, r))

    elif shape == MapShape.Square:
      var top = floor(-radius / 2)
      var left = floor(-radius / 2)
      var bottom = floor(radius / 2)
      var right = floor(radius / 2)
      for r in range(top, bottom):
        var r_offset = floor(r/2)
        for q in range(left - r_offset, right - r_offset):
          hexes.push_back(HexPrototype.new(q, r))
    
    generate_terrain(hexes)

    return hexes

static func pixel_to_pointy_hex(x: float, y: float) -> Coordinate:
    var _x = x / HEX_LAYOUT_SIZE_X;
    var _y = y / HEX_LAYOUT_SIZE_Y;
    var q = POINTY_HEX_MATRIX.b0 * _x + POINTY_HEX_MATRIX.b1 * _y;
    var r = POINTY_HEX_MATRIX.b2 * _x + POINTY_HEX_MATRIX.b3 * _y;
    return axial_round(q, r)

static func axial_round(fraq_q: float, fraq_r: float) -> Coordinate:
    var fraq_s = -fraq_q - fraq_r;
    var q = round(fraq_q)
    var r = round(fraq_r)
    var s = round(fraq_s)

    var q_diff = abs(q - fraq_q)
    var r_diff = abs(r - fraq_r)
    var s_diff = abs(s - fraq_s)

    if q_diff > r_diff && q_diff > s_diff:
        q = -r - s
    elif r_diff > s_diff:
        r = -q - s;

    return Coordinate.new(q, r)

static func pointy_hex_to_pixel(coordinate: Coordinate) -> Vector2:
  var q = coordinate.q
  var r = coordinate.r
  
  var x = (POINTY_HEX_MATRIX.f0 * q + POINTY_HEX_MATRIX.f1 * r) * HEX_LAYOUT_SIZE_X;
  var y = (POINTY_HEX_MATRIX.f2 * q + POINTY_HEX_MATRIX.f3 * r) * HEX_LAYOUT_SIZE_Y;

  return Vector2(x, y)

static func move_entity_to_coordinate(entity, coordinate: Coordinate):
  entity.position = pointy_hex_to_pixel(coordinate)
  
static func get_neighbor_directions() -> Array:
  return [
        Coordinate.new(1, 0 ),
        Coordinate.new(1, -1 ),
        Coordinate.new(0, -1 ),
        Coordinate.new(-1, 0 ),
        Coordinate.new(-1, 1 ),
        Coordinate.new(0, 1 ),
        ]

static func coordinate_add(coord1, coord2):
  return Coordinate.new(coord1.q + coord2.q, coord1.r + coord2.r)

#// pub fn axial_distance(a: Coordinate, b: Coordinate) -> i32 {
#//     ((a.q - b.q).abs() + (a.q + a.r - b.q - b.r).abs() + (a.r - b.r).abs()) / 2
#// }

static func get_distance(a: Coordinate, b: Coordinate):
  return (abs(a.q - b.q) + abs(a.q + a.r - b.q - b.r) + abs(a.r - b.r)) / 2
