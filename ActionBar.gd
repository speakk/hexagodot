extends Control

export var movement_points: int setget _set_movement_points
export var attack_points: int setget _set_attack_points

const MOVEMENT_POINT = preload("MovementPoint.tscn")
const ATTACK_POINT = preload("AttackPoint.tscn")

func _update_display():
  for n in $Points.get_children():
    $Points.remove_child(n)
    n.queue_free()
  
  for i in range(0,movement_points):
    var point = MOVEMENT_POINT.instance()
    point.visible = true
    $Points.add_child(point)
  
  for i in range(0,attack_points):
    var point = ATTACK_POINT.instance()
    point.visible = true
    $Points.add_child(point)

func _set_movement_points(_value):
  movement_points = _value
  _update_display()
  
func _set_attack_points(_value):
  attack_points = _value
  _update_display()
  
