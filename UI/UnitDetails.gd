extends VBoxContainer

var unit: Unit

func _ready():
  Events.connect("unit_took_damage", self, "_on_unit_took_damage")
  Events.connect("unit_moved", self, "_on_unit_moved")
  Events.connect("unit_selected", self, "set_unit")
  Events.connect("deselected", self, "_on_deselected")
  
  set_unit(null)

func set_unit(value):
  unit = value
  redraw()

func _on_unit_took_damage(_a, _b):
  redraw()

func _on_deselected():
  set_unit(null)

func _on_unit_moved(_a, _b, _c):
  redraw()

func redraw():
  if unit:
    $CenterContainer.visible = true
    $UnitTypeLabel.text = unit.unit_name
    get_node("%HP_Label").text = "%s/%s" % [unit.health, unit.max_health]
    get_node("%Movement_Label").text = "%s/%s" % [unit.movement_points, unit.max_movement_points]
    
  else:
    $CenterContainer.visible = false
    $UnitTypeLabel.text = "No unit selected"
