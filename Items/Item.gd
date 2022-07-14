extends Node2D

class_name Item

var solid = false
var spawn_chance: float = 0
var item_name := ""
var category
var action_point_cost = 0

func get_texture():
  return $Sprite.texture
