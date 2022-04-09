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

static func create_grid(radius: int, shape) -> Array:
    var hexes: Array = []

    if shape == MapShape.Hexagonal:
      for q in range(-radius, radius):
                var r1: int = int(max(-radius, -q - radius))
                var r2: int = int(min(radius, -q + radius))

                for r in range(r1,r2):
                    hexes.push_back(Coordinate.new(q, r))
            # }
            #
            #        MapShape::Square => {
            #            let top = ((-radius / 2) as f32).floor() as i32;
            #            let left = ((-radius / 2) as f32).floor() as i32;
            #            let bottom = ((radius / 2) as f32).floor() as i32;
            #            let right = ((radius / 2) as f32).floor() as i32;
            #            for r in top..bottom {
            #                let r_offset = ((r / 2) as f32).floor() as i32;
            #                for q in left - r_offset..right - r_offset {
            #                    hexes.push(Coordinate { q, r });
            #                }
            #            }
            #        }
            #    }

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

