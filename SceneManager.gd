extends Node2D

func get_current_scene():
  var nextViewportContainer = $Containers.get_child(0)
  var scene = nextViewportContainer.get_child(0).get_child(0)
  return scene

func get_current_viewport():
  return $Containers.get_child(0).get_child(0)

func switch_scenes(sceneName):
  var to_scene = load("res://MainScenes/%s.tscn" % sceneName).instance()
  
  var current_index = 0
  var next_index = 1
  
  var nextViewportContainer = $Containers.get_child(next_index)
  var nextViewportNode = nextViewportContainer.get_node("Viewport")
  nextViewportNode.add_child(to_scene)
  var width = ProjectSettings.get_setting("display/window/size/width")
  print("width", width)
  nextViewportContainer.visible = true
  
  var currentViewportContainer = $Containers.get_child(current_index)
  var current_scene = currentViewportContainer.get_node("Viewport").get_child(0)
  
  var tweenLength = 0.3
  $Tween.interpolate_property(nextViewportContainer, "rect_position", Vector2(width, 0), Vector2(0, 0), tweenLength)
  $Tween.interpolate_property(currentViewportContainer, "rect_position", Vector2(0, 0), Vector2(-width, 0), tweenLength)
  $Tween.start()
  
  yield($Tween, "tween_all_completed")
  
  if current_scene:
    currentViewportContainer.visible = false
    if current_scene.has_method("clean_up_scene"):
      current_scene.clean_up_scene()
    current_scene.queue_free()
    
  # Move current to the bottom (despite the name "raise") so that NEXT scene will now be index 0
  currentViewportContainer.raise()
  if to_scene.has_method("enter_scene"):
    to_scene.enter_scene()
