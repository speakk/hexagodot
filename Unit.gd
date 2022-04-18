extends Node2D

class_name Unit

var team

export var q: int
export var r: int
export var selected: bool = false
export var health: int = 4 setget _set_health
export var max_health: int = health
export var damage_amount: int = 1

func init(_q, _r):
  q = _q
  r = _r
  #MapTools.move_entity_to_coordinate(self, Coordinate.new(_q, _r))
  $HealthBar.max_value = max_health
  $HealthBar.value = health
  return self
  
func place(_q, _r):
  q = _q
  r = _r
  
func get_coordinate():
  return Coordinate.new(q, r)

func select():
  selected = true
  $SelectRing.visible = true

func deselect():
  selected = false
  $SelectRing.visible = false

func set_team(_team):
  team = _team
  $TeamIcon.color = team.color

func take_damage(amount):
  _set_health(health - amount)
  
func _set_health(value):
  health = value
  $HealthBar.value = health
