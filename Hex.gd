extends Node2D

class_name Hex

export var q = 0
export var r = 0

var hovered = false

signal hex_clicked(Hex)

func init(_q, _r):
  q = _q
  r = _r
  MapTools.move_entity_to_coordinate(self, Coordinate.new(_q, _r))
  return self

const HOVER_COLOR = Color(1, 0.3, 0.4)

func _on_mouse_entered():
  hovered = true
  $Hexagon.modulate = HOVER_COLOR
  $HoverTween.remove_all()

func _on_mouse_exited():
  hovered = false
  $HoverTween.interpolate_property($Hexagon, "modulate",
  HOVER_COLOR, Color(1,1,1), 0.5,
  $HoverTween.TRANS_QUAD, Tween.EASE_OUT)
  
  $HoverTween.start()


func _on_input_event(viewport, event, shape_idx):
  if event is InputEventMouseButton:
    if event.button_index == BUTTON_LEFT and event.pressed:
      emit_signal("hex_clicked", self)


func to_coordinate():
  return Coordinate.new(q, r)
