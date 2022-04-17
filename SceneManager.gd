extends Node2D

var current_index = 0

func get_current_scene():
  var nextViewportContainer = $Containers.get_child(current_index)
  var scene = nextViewportContainer.get_child(0).get_child(0)
  return scene

func switch_scenes(sceneName):
  var to_scene = load("res://MainScenes/%s.tscn" % sceneName).instance()
  
  var next_index = 1 if current_index == 0 else 0
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
    current_scene.queue_free()
    
  nextViewportContainer.raise()
    
  current_index = next_index
