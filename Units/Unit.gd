extends Node2D

class_name Unit

const UNIT_DEATH = preload("res://Effects/UnitDeath.tscn")

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
export var unit_name: String = ""

export var ai_controlled: bool = false

const is_unit = true

var unit_type

func _ready():
  $Sprite.material = $Sprite.material.duplicate()
  $DamageNumberProto.visible = false

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
  Events.emit_signal("unit_took_damage", self, amount)
  
  show_damage_amount(amount)
  
  if health <= 0:
    alive = false
    Events.emit_signal("unit_died", self)
    if unit_type == UnitDB.UnitType.HERO:
      Events.emit_signal("hero_died", self)
    #self.queue_free()
    self.set_alive(false)
    var death_anim = UNIT_DEATH.instance()
    #death_anim.global_position = global_position
    get_parent().get_parent().add_child(death_anim)

const THEME = preload("res://themes/in_game_theme.tres")

func show_damage_amount(amount):
  var number_node = $DamageNumberProto.duplicate()
  var label = number_node.get_node("Label")
  label.text = "-%s" % amount
  label.modulate = Color(1, 0, 0)
  number_node.visible = true
  get_parent().get_parent().add_child(number_node)
  $DamageTween.interpolate_property(number_node, "position:y", -40, -60, 0.5)
  $DamageTween.start()
  yield($DamageTween, "tween_completed")
  number_node.queue_free()

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
  #$Tween.remove_all()
  $Tween.remove($Sprite.material, "shader_param/whiteness")
  $Tween.interpolate_property($Sprite.material, "shader_param/whiteness", 1.0, 0.0, 0.4)
  $Tween.start()

func consume_item(item):
  if item.has_method("apply_bonus"):
    item.apply_bonus(self)
    
  item.queue_free()
