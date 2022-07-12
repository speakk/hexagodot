extends Control

export var action_points: int setget _set_action_points

const MOVEMENT_POINT = preload("MovementPoint.tscn")

func _update_display():
  for n in $Points.get_children():
    $Points.remove_child(n)
    n.queue_free()
  
  for i in range(0,action_points):
    var point = MOVEMENT_POINT.instance()
    point.visible = true
    $Points.add_child(point)

func _set_action_points(_value):
  action_points = _value
  _update_display()
