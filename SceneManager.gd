extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var current_scene
var current_index = 0

# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.

func switch_scenes(sceneName):
  var to_scene = load("res://MainScenes/%s.tscn" % sceneName).instance()
  
  var next_index = 1 if current_index == 0 else 0
  var nextViewportContainer = get_child(next_index)
  nextViewportContainer.get_node("Viewport").add_child(to_scene)
  nextViewportContainer.visible = true
  
 
  var currentViewportContainer = get_child(current_index)
  currentViewportContainer.visible = false
  var current_scene = currentViewportContainer.get_node("Viewport").get_child(0)
  if current_scene:
    current_scene.queue_free()
    
  nextViewportContainer.raise()
    
  current_index = next_index
