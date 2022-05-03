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
export var attack_range: int = 1

export var ai_controlled: bool = false

var unit_type

func _ready():
  $Sprite.material = $Sprite.material.duplicate()

func init(type):
  unit_type = type
  return self

func place(_q, _r, movement_points = 0):
  q = _q
  r = _r
  if movement_points:
    use_movement_points(movement_points)
  
func get_coordinate():
  return Coordinate.new(q, r)

func set_ai_controlled(value):
  ai_controlled = value

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
  
  if team.controller == Team.ControllerType.AI:
    set_ai_controlled(true)

func take_damage(amount):
  _set_health(health - amount)
  flash_white()
  if health <= 0:
    alive = false
    emit_signal("unit_died", self)
    #self.queue_free()
    self.set_alive(false)
  
func _set_health(value):
  health = value
  $HealthBar.value = health

func set_alive(value):
  alive = value
  visible = value

func _set_movement_points(value):
  movement_points = value
  $ActionBar.movement_points = movement_points

func use_movement_points(amount):
  _set_movement_points(movement_points - amount)

func _set_attack_points(value):
  attack_points = value
  $ActionBar.attack_points = attack_points

func use_attack_points(amount):
  _set_attack_points(attack_points - amount)

# Default implementation, can be overridden
func process_turn():
  yield(get_tree(), "idle_frame")
  if alive:
    if ai_controlled:
      yield(AI.attack_closest_enemy(self), "completed")

func flash_white():
  $Tween.remove_all()
  $Tween.interpolate_property($Sprite.material, "shader_param/whiteness", 1.0, 0.0, 0.5)
  $Tween.start()
