extends Node2D

class_name Unit

signal unit_died(unit)

var team

export var q: int
export var r: int
export var selected: bool = false
export var health: int = 4 setget _set_health
export var max_health: int = health
export var damage_amount: int = 1
export var alive: bool = true

var unit_type

func init(_q, _r, type):
  q = _q
  r = _r
  unit_type = type
  UnitDB.load_db_values(self, type)
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
  if health <= 0:
    alive = false
    self.queue_free()
  
func _set_health(value):
  health = value
  $HealthBar.value = health
