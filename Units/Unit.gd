extends Node2D

class_name Unit

const UNIT_DEATH = preload("res://Effects/UnitDeath.tscn")
const PROJECTILE = preload("res://Projectile.tscn")

var team

export var q: int
export var r: int
export var selected: bool = false
export var health: int = 4 setget _set_health
export var max_health: int = health
export var damage_amount: int = 1
export var alive: bool = true
export var action_points: int = 5
export var max_action_points: int = action_points
export var attack_range: int = 1
export var unit_name: String = ""

export var ai_controlled: bool = false

const is_unit = true

var unit_type
var selected_attack_slot_id

onready var equipment_handler = EquipmentHandler.new(self)

func _ready():
  $Sprite.material = $Sprite.material.duplicate()
  $DamageNumberProto.visible = false
  $HealthNumberProto.visible = false
  Events.connect("attack_selected", self, "_on_attack_selected")

func init(type):
  unit_type = type
  return self

# TODO: selected_attack_slot_id probably shouldn't be stored in Unit but in some UI thing
# because it's only used when attacking via UI
func _on_attack_selected(_unit, slot_id, item):
  if _unit == self:
    selected_attack_slot_id = slot_id
  else:
    selected_attack_slot_id = null

func get_selected_attack_item():
  if selected_attack_slot_id:
    return equipment_handler.get_slot_item(selected_attack_slot_id)

func place(_q, _r, action_points = 0):
  q = _q
  r = _r
  if action_points:
    use_action_points(action_points)
  
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
  _set_action_points(max_action_points)

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

func heal(amount):
  if health + amount > max_health:
    return false
  _set_health(health + amount)
  show_healing_amount(amount)
  
func show_healing_amount(amount):
  var number_node = $HealthNumberProto.duplicate()
  var label = number_node.get_node("Label")
  label.text = "-%s" % amount
  number_node.visible = true
  get_parent().get_parent().add_child(number_node)
  $HealthTween.interpolate_property(number_node, "position:y", -40, -60, 0.5)
  $HealthTween.start()
  yield($HealthTween, "tween_completed")
  number_node.queue_free()

const THEME = preload("res://themes/in_game_theme.tres")

func show_damage_amount(amount):
  var number_node = $DamageNumberProto.duplicate()
  var label = number_node.get_node("Label")
  label.text = "-%s" % amount
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

func _set_action_points(value):
  action_points = value
  $ActionBar.action_points = action_points

func use_action_points(amount):
  _set_action_points(action_points - amount)

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

func pick_up_item(item):
  item.get_parent().remove_child(item)
  team.add_item_to_inventory(item)
  
func get_equipped_item(slot_id):
  return equipment_handler.get_slot_item(slot_id)

func perform_ranged_attack_animation(against):
  print("perform_ranged_attack_animation")
  var projectile = PROJECTILE.instance()
  get_parent().get_parent().add_child(projectile)
  projectile.global_position = global_position
  projectile.z_index = 2
  $ProjectileTween.interpolate_property(projectile, "global_position", projectile.global_position, against.global_position, 0.3)
  $ProjectileTween.start()
  yield($ProjectileTween, "tween_completed")
  projectile.queue_free()
