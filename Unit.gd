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
export var movement_points: int = 5
export var max_movement_points: int = movement_points
export var attack_points: int = 1
export var max_attack_points: int = attack_points

var unit_type

func init(_q, _r, type):
  q = _q
  r = _r
  unit_type = type
  UnitDB.load_db_values(self, type)
  $HealthBar.max_value = max_health
  $HealthBar.value = health
  $ActionBar.attack_points = attack_points
  $ActionBar.movement_points = movement_points
  return self
  
func place(_q, _r, movement_points = 0):
  q = _q
  r = _r
  if movement_points:
    use_movement_points(movement_points)
  
func get_coordinate():
  return Coordinate.new(q, r)

func select():
  selected = true
  $SelectRing.visible = true

func deselect():
  selected = false
  $SelectRing.visible = false

func reset_points():
  _set_movement_points(max_movement_points)
  _set_attack_points(max_attack_points)

func set_team(_team):
  team = _team
  add_to_group("unit_in_team")
  add_to_group(team.team_name)
  print("Adding to name...", team.team_name)
  $TeamIcon.color = team.color

func take_damage(amount):
  _set_health(health - amount)
  if health <= 0:
    alive = false
    self.queue_free()
  
func _set_health(value):
  health = value
  $HealthBar.value = health

func _set_movement_points(value):
  movement_points = value
  $ActionBar.movement_points = movement_points

func use_movement_points(amount):
  _set_movement_points(movement_points - amount)

func _set_attack_points(value):
  attack_points = value
  $ActionBar.attack_points = attack_points
