extends Control

export var max_value: int
export var value: int setget _set_value

const HEALTH_POINT = preload("HealthPoint.tscn")

func _set_value(_value):
  value = _value
  for n in $Points.get_children():
    $Points.remove_child(n)
    n.queue_free()
  
  for i in range(0,value):
    var point = HEALTH_POINT.instance()
    point.visible = true
    $Points.add_child(point)
