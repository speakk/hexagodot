extends YSort

class_name Hex

export var q = 0
export var r = 0
export var path_hilight: bool = false

var hovered = false

signal hex_clicked(Hex)
signal hex_hovered(Hex)
signal hex_hovered_exited(Hex)

func init(_q, _r):
  q = _q
  r = _r

  MapTools.move_entity_to_coordinate(self, Coordinate.new(_q, _r))
  return self

const BASE_COLOR = Color(1, 1, 1)
const HOVER_COLOR = Color(1, 0.3, 0.4)
const HILIGHT_COLOR = Color(1, 1, 0.0)

func _process(dt):
  if path_hilight:
    $Hexagon.modulate = HILIGHT_COLOR
    $PathHilightIndicator.visible = true
  else:
    $PathHilightIndicator.visible = false    
  
  if hovered:
    $Hexagon.modulate = HOVER_COLOR
  
  if not path_hilight and not hovered:
    $Hexagon.modulate = $Hexagon.modulate.linear_interpolate(BASE_COLOR, 0.15)

func _on_mouse_entered():
  hovered = true
  emit_signal("hex_hovered", self)

func _on_mouse_exited():
  emit_signal("hex_hover_exited", self)
  hovered = false

func _on_input_event(viewport, event, shape_idx):
  if event is InputEventMouseButton:
    if event.button_index == BUTTON_LEFT and event.pressed:
      emit_signal("hex_clicked", self)

func get_units():
  return $Units.get_children()

func to_coordinate():
  return Coordinate.new(q, r)
